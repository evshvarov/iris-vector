iris-vector
==

Basic support Vector datatype for IRIS SQL.

Installtion
- 

Install with IPM

```objectscript
zpm "install vector"
```

Or run this project with docker-compose in development mode

Usage
-

```SQL
create table items(embedding vector(3));
insert into items (embedding) values ('[1,2,3]');
insert into items (embedding) values ('[4,5,6]');
```

SQL Functions
-

* Normalize

```
[SQL]irisowner@/usr/irissys/:USER> select embedding,vector.norm(embedding) from items;
+-----------+--------------------+
| embedding | Expression_2       |
+-----------+--------------------+
| [1,2,3]   | 3.7416573867739413 |
| [4,5,6]   | 8.774964387392123  |
+-----------+--------------------+
2 rows in set
Time: 0.065s
```

* sum two vectors

```
[SQL]irisowner@/usr/irissys/:USER> select embedding,vector.vector_add(embedding, '[1,1,1]') from items;
+-----------+--------------+
| embedding | Expression_2 |
+-----------+--------------+
| [1,2,3]   | [2,3,4]      |
| [4,5,6]   | [5,6,7]      |
+-----------+--------------+
2 rows in set
Time: 0.066s
```

* Euclidean distance

```
[SQL]irisowner@/usr/irissys/:USER> select embedding, vector.l2_distance(embedding, '[9,8,7]') distance from items order by distance;
+-----------+----------------------+
| embedding | distance             |
+-----------+----------------------+
| [4,5,6]   | 5.916079783099616045 |
| [1,2,3]   | 10.77032961426900807 |
+-----------+----------------------+
2 rows in set
Time: 0.012s
```

* Cosine similarity

```
[SQL]irisowner@/usr/irissys/:USER> select embedding, vector.cosine_distance(embedding, '[9,8,7]') distance from items order by distance;
+-----------+---------------------+
| embedding | distance            |
+-----------+---------------------+
| [4,5,6]   | .034536677566264152 |
| [1,2,3]   | .11734101007866331  |
+-----------+---------------------+
2 rows in set
Time: 0.065s
```

* Inner product

```
[SQL]irisowner@/usr/irissys/:USER> select embedding, -vector.inner_product(embedding, '[9,8,7]') distance from items order by distance;
+-----------+----------+
| embedding | distance |
+-----------+----------+
| [4,5,6]   | -118     |
| [1,2,3]   | -46      |
+-----------+----------+
2 rows in set
Time: 0.062s
```

Indexing
-

Not implemented yet
