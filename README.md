# ![](https://gravatar.com/avatar/11d3bc4c3163e3d238d558d5c9d98efe?s=64) Git-R-Done

[![Docker Repository on Quay.io](https://quay.io/repository/aptible/redis/status)](https://quay.io/repository/aptible/redis)

Simple Sinatra app to display GitHub issues according to tidiness rules

## Usage

    git clone https://github.com/aptible/gitrdone
    cd gitrdone/
    bundle install
    bundle exec ruby app.rb

## Configuration

Git-R-Done is configured through environment variables. The following variables may be set:

| Environment Variable | Description |
| -------------------- | ----------- |
| `GITHUB_CRITERIA` | JSON mapping issue labels to "constraints" |
| `GITHUB_LABELS` | Comma-separated list of all issue labels |
| `GITHUB_TOKEN` | Token used for accessing GitHub API |
| `GITHUB_ORG` | Name of GitHub org |

Here's an example JSON value for `ENV['GITHUB_CRITERIA']`, demonstrating what constraint keys/values are possible:

    {
      "none": { "min_age": 7, "max_age": 365 },
      "ready": { "max_count": 90 },
      "on deck": { "max_count": 60 },
      "in progress": { "max_count": 18 }
    }

## Copyright and License

MIT License, see [LICENSE](LICENSE.md) for details.

Copyright (c) 2015 [Aptible](https://www.aptible.com) and contributors.

[<img src="https://s.gravatar.com/avatar/f7790b867ae619ae0496460aa28c5861?s=60" style="border-radius: 50%;" alt="@fancyremarker" />](https://github.com/fancyremarker)
