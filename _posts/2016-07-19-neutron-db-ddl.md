---
title: "neutron db DDL"
layout: post
category: openstack
---

### error

```
# su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade juno" neutron
No handlers could be found for logger "oslo_config.cfg"
INFO  [alembic.runtime.migration] Context impl MySQLImpl.
INFO  [alembic.runtime.migration] Will assume non-transactional DDL.
Traceback (most recent call last):
  File "/usr/bin/neutron-db-manage", line 10, in <module>
    sys.exit(main())
  File "/usr/lib/python2.7/site-packages/neutron/db/migration/cli.py", line 749, in main
    return_val |= bool(CONF.command.func(config, CONF.command.name))
  File "/usr/lib/python2.7/site-packages/neutron/db/migration/cli.py", line 223, in do_upgrade
    run_sanity_checks(config, revision)
  File "/usr/lib/python2.7/site-packages/neutron/db/migration/cli.py", line 731, in run_sanity_checks
    script_dir.run_env()
  File "/usr/lib/python2.7/site-packages/alembic/script/base.py", line 397, in run_env
    util.load_python_file(self.dir, 'env.py')
  File "/usr/lib/python2.7/site-packages/alembic/util/pyfiles.py", line 81, in load_python_file
    module = load_module_py(module_id, path)
  File "/usr/lib/python2.7/site-packages/alembic/util/compat.py", line 79, in load_module_py
    mod = imp.load_source(module_id, path, fp)
  File "/usr/lib/python2.7/site-packages/neutron/db/migration/alembic_migrations/env.py", line 126, in <module>
    run_migrations_online()
  File "/usr/lib/python2.7/site-packages/neutron/db/migration/alembic_migrations/env.py", line 120, in run_migrations_online
    context.run_migrations()
  File "<string>", line 8, in run_migrations
  File "/usr/lib/python2.7/site-packages/alembic/runtime/environment.py", line 797, in run_migrations
    self.get_context().run_migrations(**kw)
  File "/usr/lib/python2.7/site-packages/alembic/runtime/migration.py", line 303, in run_migrations
    for step in self._migrations_fn(heads, self):
  File "/usr/lib/python2.7/site-packages/neutron/db/migration/cli.py", line 722, in check_sanity
    revision, rev, implicit_base=True):
  File "/usr/lib/python2.7/site-packages/alembic/script/revision.py", line 621, in _iterate_revisions
    uppers = util.dedupe_tuple(self.get_revisions(upper))
  File "/usr/lib/python2.7/site-packages/alembic/script/revision.py", line 304, in get_revisions
    for rev_id in resolved_id)
  File "/usr/lib/python2.7/site-packages/alembic/script/revision.py", line 304, in <genexpr>
    for rev_id in resolved_id)
  File "/usr/lib/python2.7/site-packages/alembic/script/revision.py", line 359, in _revision_for_ident
    resolved_id)
alembic.script.revision.ResolutionError: No such revision or branch 'juno'
```

### [solution](https://ask.openstack.org/en/question/52502/unable-to-configure-neutron-db-in-juno/)

```
In order to get his working try the following

instead of su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade juno" neutron

Use this instead…

su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
```
