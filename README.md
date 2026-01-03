# MusicGraph-Recomendation-engine
Este projeto implementa um sistema de recomendação de músicas utilizando o banco de dados orientado a grafos Neo4j.

📐 1. Esboço da Modelagem
Para representar os padrões de escuta e sugerir novas faixas, o grafo foi modelado da seguinte forma:


          (Usuario)
              │
      [:OUVIU {qtd}] ou [:CURTIU]
              ▼
          (Musica) ◄─── [:PERTENCE_AO] ─── (Genero)
           /    \                             ▲
          /      \                            │
  [:CANTADA_POR]  \                     [:PERTENCE_AO]
        /          \                          │
    (Artista) ◄─── [:SIMILAR_A] ────────── (Artista)
🚀 2. Como Testar
Instale o Neo4j Desktop.

Execute o script music_recommendation.cypher para criar os nós e as arestas com propriedades.

🔎 3. Algoritmos de Recomendação
Abaixo estão as 5 estratégias implementadas para gerar recomendações personalizadas com base em conexões no grafo:

1. Recomendação para ANA (Filtragem Colaborativa)
Cenário: Ana ouviu Dua Lipa. O sistema recomenda o que usuários similares (Bruno) também ouviram.

Cypher

MATCH (eu:Usuario {nome: "Ana"})-[:OUVIU|CURTIU]->(m)<-[:OUVIU|CURTIU]-(outro:Usuario)
MATCH (outro)-[:OUVIU|CURTIU]->(rec:Musica)
WHERE NOT (eu)-[:OUVIU|CURTIU]->(rec)
RETURN eu.nome, rec.titulo, count(DISTINCT outro) AS Score
ORDER BY Score DESC LIMIT 3;
Resultado:
![Resultado Ana](./img/resultado-ana.png)

2. Recomendação para DANIEL (Nicho Sertanejo)
Cenário: Daniel foca em um artista. O sistema expande para outros artistas do mesmo gênero baseando-se em fãs comuns.

Cypher

MATCH (eu:Usuario {nome: "Daniel"})-[:OUVIU|CURTIU]->(m)-[:CANTADA_POR]->(a)
MATCH (outro)-[:OUVIU|CURTIU]->(m)
MATCH (outro)-[:OUVIU|CURTIU]->(rec:Musica)-[:CANTADA_POR]->(artRec:Artista)
WHERE NOT (eu)-[:OUVIU|CURTIU]->(rec)
RETURN eu.nome, rec.titulo, artRec.nome AS Artista LIMIT 3;
Resultado:
![Resultado Daniel](./img/resultado-daniel.png)

3. Recomendação para GABRIEL (Padrão de Rock)
Cenário: Identifica que Gabriel e Helena compartilham o gosto por "Yellow" e sugere outras faixas do histórico dela.

Cypher

MATCH (eu:Usuario {nome: "Gabriel"})-[:OUVIU|CURTIU]->(m)<-[:OUVIU|CURTIU]-(outro)
MATCH (outro)-[:OUVIU|CURTIU]->(rec:Musica)
WHERE NOT (eu)-[:OUVIU|CURTIU]->(rec)
RETURN eu.nome, rec.titulo AS Sugestao LIMIT 2;
Resultado:
![Resultado Gabriel](./img/resultado-gabriel.png)

4. Recomendação para JULIA (Cold Start)
Cenário: Julia é nova. O sistema usa interações mínimas para encontrar o vizinho mais próximo (Kevin).

Cypher

MATCH (eu:Usuario {nome: "Julia"})-[:OUVIU|CURTIU]->(m)<-[:OUVIU|CURTIU]-(outro)
MATCH (outro)-[:OUVIU|CURTIU]->(rec:Musica)
WHERE NOT (eu)-[:OUVIU|CURTIU]->(rec)
RETURN eu.nome, rec.titulo AS Sugestao LIMIT 2;
Resultado:
![Resultado Julia](./img/resultado-julia.png)

5. Recomendação Avançada para BRUNO (Ontologia)
Cenário: Usa a relação [:SIMILAR_A] entre artistas para sugerir conteúdo novo de forma inteligente.

Cypher

MATCH (u:Usuario {nome: "Bruno"})-[:OUVIU|CURTIU]->(m:Musica)-[:CANTADA_POR]->(a:Artista)
MATCH (a)-[:SIMILAR_A]-(artistaParecido:Artista)<-[:CANTADA_POR]-(rec:Musica)
WHERE NOT (u)-[:OUVIU|CURTIU]->(rec)
RETURN u.nome, rec.titulo, "Porque você gosta de " + a.nome AS Motivo LIMIT 3;
Resultado:
![Resultado Bruno](./img/resultado-bruno.png)