`pingdom`: The Cog Pingdom Command Bundle
=========================================

Access [Pingdom](https://pingdom.com) check information via Cog.

* `pingdom:check list` - retrieve list of all checks
* `pingdom:check show <id>` - get detailed information for a specific check
* `pingdom:check results <id> --count=count` - retrieve 'count' raw check results for a specific check. Defaults to 1.

# Installing

    curl -O https://github.com/cogcmd/pingdom/blob/master/config.yaml
    cogctl bundle install config.yaml

# Building

To build the Docker image, simply run:

    $ rake image

Requires Docker and Rake.
