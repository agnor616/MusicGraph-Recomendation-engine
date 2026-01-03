// ============================================
// 1. LIMPEZA E CONSTRAINTS
// ============================================
MATCH (n) DETACH DELETE n;

CREATE CONSTRAINT IF NOT EXISTS FOR (u:Usuario) REQUIRE u.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (m:Musica) REQUIRE m.titulo IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (a:Artista) REQUIRE a.nome IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (g:Genero) REQUIRE g.nome IS UNIQUE;

// ============================================
// 2. CRIAR BASE (Gêneros, Artistas e Similaridades)
// ============================================
UNWIND [
  {nome: "Pop", artistas: ["Dua Lipa", "Ed Sheeran", "The Weeknd"]},
  {nome: "Rock", artistas: ["Coldplay", "Queen", "Imagine Dragons"]},
  {nome: "Sertanejo", artistas: ["Gusttavo Lima", "Marília Mendonça", "Jorge & Mateus"]},
  {nome: "Eletrônica", artistas: ["Alok", "David Guetta", "Calvin Harris"]},
  {nome: "MPB", artistas: ["Caetano Veloso", "Gilberto Gil", "Anavitória"]}
] AS genData
MERGE (g:Genero {nome: genData.nome})
FOREACH (artNome IN genData.artistas | 
  MERGE (a:Artista {nome: artNome})
  MERGE (a)-[:PERTENCE_AO]->(g)
);

// --- DEFININDO SIMILARIDADES (O "Cérebro" da Recomendação 5) ---
MATCH (a1:Artista {nome: "Dua Lipa"}), (a2:Artista {nome: "The Weeknd"}) MERGE (a1)-[:SIMILAR_A]->(a2);
MATCH (a1:Artista {nome: "Dua Lipa"}), (a2:Artista {nome: "Ed Sheeran"}) MERGE (a1)-[:SIMILAR_A]->(a2); // ADICIONADO PARA O BRUNO
MATCH (a1:Artista {nome: "Gusttavo Lima"}), (a2:Artista {nome: "Jorge & Mateus"}) MERGE (a1)-[:SIMILAR_A]->(a2);
MATCH (a1:Artista {nome: "Queen"}), (a2:Artista {nome: "Coldplay"}) MERGE (a1)-[:SIMILAR_A]->(a2);
MATCH (a1:Artista {nome: "Alok"}), (a2:Artista {nome: "David Guetta"}) MERGE (a1)-[:SIMILAR_A]->(a2);

// ============================================
// 3. CRIAR MÚSICAS
// ============================================
UNWIND [
  {titulo: "Levitating", artista: "Dua Lipa", genero: "Pop"},
  {titulo: "Shape of You", artista: "Ed Sheeran", genero: "Pop"},
  {titulo: "Blinding Lights", artista: "The Weeknd", genero: "Pop"},
  {titulo: "Yellow", artista: "Coldplay", genero: "Rock"},
  {titulo: "Bohemian Rhapsody", artista: "Queen", genero: "Rock"},
  {titulo: "Believer", artista: "Imagine Dragons", genero: "Rock"},
  {titulo: "Bloqueado", artista: "Gusttavo Lima", genero: "Sertanejo"},
  {titulo: "Infiel", artista: "Marília Mendonça", genero: "Sertanejo"},
  {titulo: "Sosseguei", artista: "Jorge & Mateus", genero: "Sertanejo"},
  {titulo: "Hear Me Now", artista: "Alok", genero: "Eletrônica"},
  {titulo: "Titanium", artista: "David Guetta", genero: "Eletrônica"},
  {titulo: "Summer", artista: "Calvin Harris", genero: "Eletrônica"},
  {titulo: "Leãozinho", artista: "Caetano Veloso", genero: "MPB"},
  {titulo: "Trevo", artista: "Anavitória", genero: "MPB"}
] AS musData
MERGE (m:Musica {titulo: musData.titulo})
MERGE (a:Artista {nome: musData.artista})
MERGE (g:Genero {nome: musData.genero})
MERGE (m)-[:CANTADA_POR]->(a)
MERGE (m)-[:PERTENCE_AO]->(g);

// ============================================
// 4. CRIAR USUÁRIOS E INTERAÇÕES
// ============================================
UNWIND [
  {id:"U1", nome:"Ana"}, {id:"U2", nome:"Bruno"}, {id:"U3", nome:"Carla"}, 
  {id:"U4", nome:"Daniel"}, {id:"U5", nome:"Eduardo"}, {id:"U6", nome:"Fernanda"}, 
  {id:"U7", nome:"Gabriel"}, {id:"U8", nome:"Helena"}, {id:"U9", nome:"Igor"}, 
  {id:"U10", nome:"Julia"}, {id:"U11", nome:"Kevin"}, {id:"U12", nome:"Larissa"}, 
  {id:"U13", nome:"Marcos"}, {id:"U14", nome:"Natalia"}, {id:"U15", nome:"Otavio"}
] AS uData
MERGE (:Usuario {id: uData.id, nome: uData.nome});

// Perfil Pop (Ana, Bruno, Carla)
MATCH (u:Usuario {nome: "Ana"}), (m:Musica {titulo: "Levitating"}) MERGE (u)-[:OUVIU {qtd: 15}]->(m);
MATCH (u:Usuario {nome: "Ana"}), (m:Musica {titulo: "Shape of You"}) MERGE (u)-[:CURTIU]->(m);

MATCH (u:Usuario {nome: "Bruno"}), (m:Musica {titulo: "Levitating"}) MERGE (u)-[:OUVIU {qtd: 5}]->(m);
MATCH (u:Usuario {nome: "Bruno"}), (m:Musica {titulo: "Blinding Lights"}) MERGE (u)-[:CURTIU]->(m); 

MATCH (u:Usuario {nome: "Carla"}), (m:Musica {titulo: "Shape of You"}) MERGE (u)-[:OUVIU {qtd: 8}]->(m);
MATCH (u:Usuario {nome: "Carla"}), (m:Musica {titulo: "Summer"}) MERGE (u)-[:CURTIU]->(m);

// Perfil Sertanejo (Daniel, Eduardo, Fernanda)
MATCH (u:Usuario {nome: "Daniel"}), (m:Musica {titulo: "Bloqueado"}) MERGE (u)-[:OUVIU {qtd: 20}]->(m);
MATCH (u:Usuario {nome: "Eduardo"}), (m:Musica {titulo: "Bloqueado"}) MERGE (u)-[:CURTIU]->(m);
MATCH (u:Usuario {nome: "Eduardo"}), (m:Musica {titulo: "Infiel"}) MERGE (u)-[:OUVIU {qtd: 10}]->(m);
MATCH (u:Usuario {nome: "Fernanda"}), (m:Musica {titulo: "Infiel"}) MERGE (u)-[:CURTIU]->(m);
MATCH (u:Usuario {nome: "Fernanda"}), (m:Musica {titulo: "Sosseguei"}) MERGE (u)-[:OUVIU {qtd: 3}]->(m);

// Perfil Rock (Gabriel, Helena, Igor)
MATCH (u:Usuario {nome: "Gabriel"}), (m:Musica {titulo: "Yellow"}) MERGE (u)-[:CURTIU]->(m);
MATCH (u:Usuario {nome: "Helena"}), (m:Musica {titulo: "Yellow"}) MERGE (u)-[:OUVIU {qtd: 12}]->(m);
MATCH (u:Usuario {nome: "Helena"}), (m:Musica {titulo: "Bohemian Rhapsody"}) MERGE (u)-[:CURTIU]->(m);
MATCH (u:Usuario {nome: "Igor"}), (m:Musica {titulo: "Believer"}) MERGE (u)-[:OUVIU {qtd: 30}]->(m); 
MATCH (u:Usuario {nome: "Igor"}), (m:Musica {titulo: "Bohemian Rhapsody"}) MERGE (u)-[:CURTIU]->(m);

// Perfil Eletrônica/Novos (Julia, Kevin)
MATCH (u:Usuario {nome: "Julia"}), (m:Musica {titulo: "Hear Me Now"}) MERGE (u)-[:OUVIU {qtd: 2}]->(m);
MATCH (u:Usuario {nome: "Kevin"}), (m:Musica {titulo: "Titanium"}) MERGE (u)-[:CURTIU]->(m);
MATCH (u:Usuario {nome: "Kevin"}), (m:Musica {titulo: "Hear Me Now"}) MERGE (u)-[:OUVIU {qtd: 5}]->(m);