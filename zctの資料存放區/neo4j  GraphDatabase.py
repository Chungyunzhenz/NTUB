from neo4j import GraphDatabase

class Neo4jHandler:

    def __init__(self, uri, user, password):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))

    def close(self):
        self.driver.close()

    def create_node_if_not_exists(self, label, name):
        with self.driver.session() as session:
            session.execute_write(self._create_node_if_not_exists, label, name)

    @staticmethod
    def _create_node_if_not_exists(tx, label, name):
        query = (
            f"MERGE (n:{label} {{name: $name}}) "
            "RETURN n"
        )
        tx.run(query, name=name)

    def create_relationship(self, label1, name1, label2, name2, relationship):
        with self.driver.session() as session:
            session.execute_write(self._create_relationship, label1, name1, label2, name2, relationship)

    @staticmethod
    def _create_relationship(tx, label1, name1, label2, name2, relationship):
        query = (
            f"MATCH (a:{label1} {{name: $name1}}), (b:{label2} {{name: $name2}}) "
            f"MERGE (a)-[:{relationship}]->(b)"
        )
        tx.run(query, name1=name1, name2=name2)

def main():
    neo4j_handler = Neo4jHandler("bolt://localhost:7687", "neo4j", "null")

    nodes = ["class", "ctime", "table", "state", "lable", "teacher", "user", "translate", "ad"]
    node_names = {}

    for node in nodes:
        name = input(f"Enter name for {node}: ")
        node_names[node] = name
        neo4j_handler.create_node_if_not_exists(node.capitalize(), name)

    relationships = [
        ("Lable", node_names["lable"], "Table", node_names["table"], "表單類型"),
        ("Table", node_names["table"], "State", node_names["state"], "目前狀態"),
        ("User", node_names["user"], "Table", node_names["table"], "送出用戶"),
        ("User", node_names["user"], "Translate", node_names["translate"], "就讀科系"),
        ("Teacher", node_names["teacher"], "Translate", node_names["translate"], "所屬科系"),
        ("Table", node_names["table"], "Class", node_names["class"], "選擇課程"),
        ("Class", node_names["class"], "Ctime", node_names["ctime"], "上課時間"),
        ("Class", node_names["class"], "Teacher", node_names["teacher"], "授課教師"),
        ("Class", node_names["class"], "Translate", node_names["translate"], "開課科系"),
        ("State", node_names["state"], "Ad", node_names["ad"], "審核人員"),
    ]

    for rel in relationships:
        neo4j_handler.create_relationship(rel[0], rel[1], rel[2], rel[3], rel[4])

    neo4j_handler.close()

if __name__ == "__main__":
    main()
