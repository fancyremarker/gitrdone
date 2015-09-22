require 'json'
require 'active_support/inflector'

# A "criterion" combines a GitHub issue label (or set of nonmatching labels)
# with a constraint by which to identify "non-passing" issues (i.e, issues
# that fail to meet the constraint)
class Criterion
  attr_reader :label
  attr_reader :nonlabels
  attr_reader :constraint

  # Example ENV['GITHUB_CRITERIA'] value:
  # {
  #   "none": { "min_age": 7, "max_age": 365 },
  #   "ready": { "max_count": 90 },
  #   "on deck": { "max_count": 60 },
  #   "in progress": { "max_count": 18 }
  # }
  def self.from_env
    all_labels = ENV['GITHUB_LABELS'].split(',')
    json_str = ENV['GITHUB_CRITERIA'] || '{}'
    from_json(json_str, all_labels)
  end

  def self.from_json(json_str, all_labels)
    JSON.parse(json_str).map do |label, constraints|
      constraints.map do |key, value|
        label = (label == 'none' ? nil : label)
        nonlabels = (label ? nil : all_labels)
        new(label, nonlabels, key.to_sym => value)
      end
    end.flatten
  end

  # * label: A label to identify a ticket
  # * nonlabels: A set of labels for which, if a ticket matches "none", it
  #   is considered unlabeled
  # * constraint: A hash, must include exactly 1 of the following keys
  #   - max_count: Maximum size of label queue
  #   - max_age: Maximum age of tickets with label (in days)
  #   - min_age: Minimum age of tickets with label (in days)
  def initialize(label, nonlabels, constraint)
    @label = label
    @nonlabels = nonlabels
    @constraint = constraint
  end

  def failing_issues(issues)
    issues = issues.sort do |x, y|
      Time.parse(y['updated_at']) <=> Time.parse(x['updated_at'])
    end
    if label
      issues.select! { |x| x['labels'].include?(label) }
    elsif nonlabels
      issues.select! { |x| (x['labels'] & nonlabels).empty? }
    end

    case constraint_type
    when :min_age
      issues.select { |x| age(x) < constraint_value  }
    when :max_age
      issues.select { |x| age(x) > constraint_value  }
    when :max_count
      Array(issues[constraint_value..-1])
    end
  end

  def constraint_type
    constraint.keys.first
  end

  def constraint_value
    constraint[constraint_type]
  end

  # Age in days (decimal)
  def age(issue)
    (Time.now - Time.parse(issue['created_at'])) / (3600 * 24)
  end

  def to_s
    category = (label || 'unlabeled').titleize
    case constraint_type
    when :max_count
      "#{category} Issues (> #{constraint_value} Total Issues)"
    when :max_age
      "#{category} Issues Older Than #{constraint_value} Days"
    when :min_age
      "#{category} Issues Newer Than #{constraint_value} Days"
    end
  end
end
