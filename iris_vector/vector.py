import iris
from math import log
from random import random
from iris_dollar_list import DollarList
from heapq import heapify, heappop, heappush, heapreplace, nlargest, nsmallest

import numpy as np


def full_global_name(global_name, *keys):
    full_name = global_name
    if keys:
        keys = [f'"{el}"' if isinstance(el, str) else str(el) for el in keys]
        full_name += f'({",".join(keys)})'
    return full_name


class IRISVector(object):
    vector: DollarList

    def __init__(self, vector) -> None:
        if isinstance(vector, list):
            self.vector = DollarList.from_list(vector)
        elif isinstance(vector, bytes):
            self.vector = DollarList.from_bytes(vector)
        elif isinstance(vector, str):
            vector = bytes(vector, "latin-1")
            self.vector = DollarList.from_bytes(vector)
        else:
            raise Exception("Unknown vector format: " + str(type(vector)))

    def to_list(self):
        return self.vector.to_list()

    def to_iris(self):
        return self.vector.to_bytes()

    def __repr__(self):
        return repr([el.value for el in self])

    def __iter__(self):
        return iter(self.vector)

    def __sub__(self, value):
        return [a.value - b.value for (a, b) in zip(self, value)]

    def __add__(self, value):
        return [a.value + b.value for (a, b) in zip(self, value)]

    def __mul__(self, value):
        return [a.value * b.value for (a, b) in zip(self, value)]

    def __truediv__(self, value):
        return [a.value / b.value for (a, b) in zip(self, value)]

    def __gt__(self, value):
        return [a.value > b.value for (a, b) in zip(self, value)]

    def __lt__(self, value):
        return [a.value < b.value for (a, b) in zip(self, value)]


class IRISVectorElement:
    def __init__(self, index, id, vector=None, level=None):
        self.index = index
        self.id = id
        self._vector = vector
        self.level = level

    @property
    def vector(self):
        return IRISVector(
            self._vector if self._vector else self.index.get(["$all", self.id])
        )

    def neighbors(self, level=None):
        if not level:
            return []
        neighbors = []
        ind = ""
        while ind := self.index.order(["$graph", level, self.id, ind]):
            dist = DollarList.from_bytes(
                self.index.getAsBytes(["$graph", level, self.id, ind])
            )[0].value
            neighbors.append((dist, IRISVectorElement(self.index, ind)))
        return neighbors

    def __repr__(self):
        return f"<IRISVectorElement id={self.id} neighbors={len(self.neighbors(self.level))}>"

    def __gt__(self, value):
        return self.vector > value.vector

    def __lt__(self, value):
        return self.vector < value.vector


class IRISVectorIndexer:
    _lock_timeout = 10

    def __init__(self, index_global, using="l2", m=16, ef=64):
        self.index_global = index_global
        self.index = iris.gref(index_global)
        self.distance_func = {
            "l2": self.l2_distance,
            "cosine": self.l2_distance,
        }[using]
        assert self.distance_func
        self._m = m
        self._m0 = m * 2
        self._ml = 1 / log(m)
        self._ef = ef
        self._entry_point = None
        self.load_meta()

    def l2_distance(self, a, b):
        return np.linalg.norm(a - b)

    def cosine_distance(self, a, b):
        return np.dot(a, b) / (np.linalg.norm(a) * (np.linalg.norm(b)))

    def _distance(self, x, y):
        return self.distance_func(x, [y])[0]

    def _distances(self, x, ys):
        return [self.distance_func(x, y) for y in ys]

    def load_meta(self):
        meta = self.get()
        if not meta:
            return

    def lock(self, keys, timeout_value=None, locktype=None):
        timeout_value = timeout_value if timeout_value else self._lock_timeout
        global_name = full_global_name(self.index_global, *keys)
        if timeout_value and locktype:
            return iris.lock(global_name, timeout_value, locktype)
        elif timeout_value:
            return iris.lock(global_name, timeout_value)
        return iris.lock(global_name)

    def unlock(self, keys):
        global_name = full_global_name(self.index_global, *keys)
        return iris.unlock(global_name)

    def get(self, *keys):
        if not self.index.data(list(keys)):
            return None
        return self.index.getAsBytes(list(keys))

    def data(self, id):
        return IRISVector(self.index["$all", id])

    def get_element(self, id):
        if not id:
            return None
        vector = self.index["$all", id]
        return IRISVectorElement(self.index, id, vector)

    def insert(self, id, v):
        el = IRISVectorElement(self.index, id, v)
        top_level = self.index.get(["$meta", "top_level"], -1)
        level = int(-log(random()) * self._ml) + 1
        entry_point = self.get_element(self.index.get(["$meta", "entry"], None))

        self.index["$all", el.id] = el.vector.to_iris()
        # self.index["$vector", element.vector.to_iris()] = element.id

        if entry_point:
            dist = self.distance_func(el.vector, entry_point.vector)
            ep = [(dist, entry_point)]

            for lc in range(top_level, level, -1):
                ep = self.search_layer(el.vector, ep, 1, lc)

            for lc in range(level, -1, -1):
                level_m = self._m if lc > 0 else self._m0
                ep = self.search_layer(el.vector, ep, self._ef, lc)

                neighbors = self.select_neighbors(el.vector, ep, level_m)
                for epd, epel in neighbors:
                    self.index["$graph", lc, el.id, epel.id] = DollarList(
                        [epd]
                    ).to_bytes()
                    self.index["$graph", lc, epel.id, el.id] = DollarList(
                        [epd]
                    ).to_bytes()

        for i in range(level - top_level):
            self.index["$meta", "top_level"] = (
                self.index.get(["$meta", "top_level"], -1) + 1
            )
            self.index["$meta", "entry"] = el.id
            self.index["$graph", i, el.id] = ""

    def search_layer(self, v, ep, ef, lc):
        candidates = [(-mdist, p) for mdist, p in ep]
        heapify(candidates)

        visited = set([e.id for (d, e) in ep])

        while candidates:
            dist, c = heappop(candidates)
            mref = ep[0][0]
            if dist > -mref:
                break
            edges = [(d, e) for (d, e) in c.neighbors(lc) if e.id not in visited]
            visited.update([e.id for (_, e) in edges])
            # dists = self._distances(v, [el.vector for el in ep])
            for d, e in edges:
                mdist = -d
                if len(ep) < ef:
                    heappush(candidates, (dist, e))
                    heappush(ep, (mdist, e))
                    mref = ep[0][0]
                elif mdist > mref:
                    heappush(candidates, (dist, e))
                    heapreplace(ep, (mdist, e))
                    mref = ep[0][0]

        return ep

    def select_neighbors(self, v, c, m):
        return sorted(c)[:m]
