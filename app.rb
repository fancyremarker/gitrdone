require 'sinatra'
require 'octokit'
require 'redis'

require_relative 'models/criterion'

set :port, (ENV['PORT'] || 3000).to_i

Octokit.configure do |c|
  c.access_token = ENV['GITHUB_TOKEN']
  c.auto_paginate = true
end

get '/' do
  @github_org = ENV['GITHUB_ORG']
  @criteria = Criterion.from_env
  @issues_by_criterion = issues_by_criterion(@github_org, @criteria)

  erb :index
end

private

def redis
  Redis.new
end

def redis_expiry
  (ENV['REDIS_EXPIRY'] || '3600').to_i
end

def cached_issues(org)
  key = "gitrdone:cached_issues:#{org}"
  cached = redis.get(key)
  return JSON.parse(cached) if cached

  # Map Sawyer::Resource objects to basic hash
  issues = Octokit.org_issues(org, filter: 'all').map do |issue|
    issue_hash(issue)
  end
  redis.set(key, issues.to_json, ex: redis_expiry)
  issues
end

def issue_hash(sawyer_resource)
  {
    'number' => sawyer_resource.number,
    'title' => sawyer_resource.title,
    'labels' => sawyer_resource.labels.map(&:name),
    'repo' => sawyer_resource.repository.full_name,
    'html_url' => sawyer_resource.html_url,
    'created_at' => sawyer_resource.created_at.to_s,
    'updated_at' => sawyer_resource.updated_at.to_s
  }
end

def org_issues(org)
  @org_issues ||= cached_issues(org)
end

def issues_by_criterion(org, criteria)
  Hash[criteria.map do |criterion|
    [criterion, criterion.failing_issues(org_issues(org))]
  end]
end
