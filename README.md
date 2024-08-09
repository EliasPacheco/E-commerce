Passo a Passo para Configuração do Projeto
1º Passo - Criação das Tabelas no PostgreSQL
Execute os seguintes comandos SQL para criar as tabelas necessárias no seu banco de dados PostgreSQL:

-- Criação da tabela de usuários
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
);

-- Criação da tabela de itens no carrinho
CREATE TABLE cart_items (
    id SERIAL PRIMARY KEY,
    user_name VARCHAR(255),
    user_email VARCHAR(255),
    product_name VARCHAR(255),
    product_price NUMERIC(10, 2),
    quantity INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    image_url VARCHAR(255)
);

-- Criação da tabela de pedidos finalizados
CREATE TABLE pedidos_finalizados (
    id SERIAL PRIMARY KEY,
    user_name VARCHAR(255) NOT NULL,
    user_email VARCHAR(255) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    image_url VARCHAR(255)
);

2º Passo - Configuração e Execução do Servidor
 Instale as dependências do projeto:
  npm install
 Inicie o servidor:
  node index.js

3º Passo - Execução do Front-End Flutter Web
Execute o aplicativo Flutter:
 flutter run
 
- Com o servidor em execução e as tabelas criadas, siga estes passos no aplicativo:
- Crie uma conta no app.
- Faça login com suas credenciais.
- Nota: "Multicoisas" e "Temos Tudo" são nomes genéricos para os fornecedores.
- Adicione produtos ao carrinho.
- O contador de itens no carrinho será atualizado automaticamente.
- Finalize a compra.
- Na tela de escolha de fornecedores, há um FloatingActionButton que permite visualizar seus pedidos.
- Caso queira fazer logout, no canto superior direito tem um icone para sair
