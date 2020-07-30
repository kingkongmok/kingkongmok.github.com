---
layout: post
title: "oracle redefinition big table"
category: linux
tags: [oracle, redefinition]
---

## [redefinition](https://oracle-base.com/articles/misc/partitioning-an-existing-table)


创建两个测试表

```
-- Create and populate a small lookup table.
CREATE TABLE lookup (
  id            NUMBER(10),
  description   VARCHAR2(50)
);

ALTER TABLE lookup ADD (
  CONSTRAINT lookup_pk PRIMARY KEY (id)
);

INSERT INTO lookup (id, description) VALUES (1, 'ONE');
INSERT INTO lookup (id, description) VALUES (2, 'TWO');
INSERT INTO lookup (id, description) VALUES (3, 'THREE');
COMMIT;

-- Create and populate a larger table that we will later partition.
CREATE TABLE big_table (
  id            NUMBER(10),
  created_date  DATE,
  lookup_id     NUMBER(10),
  data          VARCHAR2(50)
);

DECLARE
  l_lookup_id    lookup.id%TYPE;
  l_create_date  DATE;
BEGIN
  FOR i IN 1 .. 1000000 LOOP
    IF MOD(i, 3) = 0 THEN
      l_create_date := ADD_MONTHS(SYSDATE, -24);
      l_lookup_id   := 2;
    ELSIF MOD(i, 2) = 0 THEN
      l_create_date := ADD_MONTHS(SYSDATE, -12);
      l_lookup_id   := 1;
    ELSE
      l_create_date := SYSDATE;
      l_lookup_id   := 3;
    END IF;
    
    INSERT INTO big_table (id, created_date, lookup_id, data)
    VALUES (i, l_create_date, l_lookup_id, 'This is some data for ' || i);
  END LOOP;
  COMMIT;
END;
/

-- Apply some constraints to the table.
ALTER TABLE big_table ADD (
  CONSTRAINT big_table_pk PRIMARY KEY (id)
);

CREATE INDEX bita_created_date_i ON big_table(created_date);

CREATE INDEX bita_look_fk_i ON big_table(lookup_id);

ALTER TABLE big_table ADD (
  CONSTRAINT bita_look_fk
  FOREIGN KEY (lookup_id)
  REFERENCES lookup(id)
);

-- Gather statistics on the schema objects
EXEC DBMS_STATS.gather_table_stats('SCOTT', 'LOOKUP', cascade => TRUE);
EXEC DBMS_STATS.gather_table_stats('SCOTT', 'BIG_TABLE', cascade => TRUE);
```

###  临时表

```
-- Create partitioned table.
CREATE TABLE big_table2 (
  id            NUMBER(10),
  created_date  DATE,
  lookup_id     NUMBER(10),
  data          VARCHAR2(50)
)
PARTITION BY RANGE (created_date)
(PARTITION big_table_2003 VALUES LESS THAN (TO_DATE('01/01/2004', 'DD/MM/YYYY')),
 PARTITION big_table_2004 VALUES LESS THAN (TO_DATE('01/01/2005', 'DD/MM/YYYY')),
 PARTITION big_table_2005 VALUES LESS THAN (MAXVALUE));
```

---

### Start the Redefinition Process


#### 使用管理测试包是否可用

```
EXEC DBMS_REDEFINITION.can_redef_table('SCOTT', 'BIG_TABLE');
```


#### 使用**start_redef_table**进行拷贝内容，相当于**insert into int_table select * from orig_table**;

```
--Alter parallelism to desired level for large tables.
--ALTER SESSION FORCE PARALLEL DML PARALLEL 8;
--ALTER SESSION FORCE PARALLEL QUERY PARALLEL 8;

BEGIN
  DBMS_REDEFINITION.start_redef_table(
    uname      => 'SCOTT',        
    orig_table => 'BIG_TABLE',
    int_table  => 'BIG_TABLE2');
END;
/
```

#### 由于拷贝过程长，拷贝后进行**sync_interim_table**同步

```

BEGIN
  dbms_redefinition.sync_interim_table(
    uname      => 'SCOTT',        
    orig_table => 'BIG_TABLE',
    int_table  => 'BIG_TABLE2');
END;
/
```

#### 使用**copy_table_dependents**拷贝index、constraints这些表对象

```
SET SERVEROUTPUT ON
DECLARE
  l_errors  NUMBER;
BEGIN
  DBMS_REDEFINITION.copy_table_dependents(
    uname            => 'SCOTT',
    orig_table       => 'BIG_TABLE',
    int_table        => 'BIG_TABLE2',
    copy_indexes     => DBMS_REDEFINITION.cons_orig_params,
    copy_triggers    => TRUE,
    copy_constraints => TRUE,
    copy_privileges  => TRUE,
    ignore_errors    => FALSE,
    num_errors       => l_errors,
    copy_statistics  => FALSE,
    copy_mvlog       => FALSE);
    
  DBMS_OUTPUT.put_line('Errors=' || l_errors);
END;
/
```

#### 检查后**finish_redef_table**完成更换对象名，相当于更换表、索引、等名称

```

BEGIN
  dbms_redefinition.finish_redef_table(
    uname      => 'SCOTT',        
    orig_table => 'BIG_TABLE',
    int_table  => 'BIG_TABLE2');
END;
/
```

#### drop table BIG_TABLE2;
