const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const { Pool } = require('pg');

const app = express();
app.use(bodyParser.json());
app.use(cors());

const pool = new Pool({
    user: 'postgres',
    host: '127.0.0.1',
    database: 'ecommerce',
    password: '1234',
    port: 5432,
});

// Rota para cadastro de usuário
app.post('/register', async (req, res) => {
    const { name, email, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

    try {
        const result = await pool.query(
            'INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING *',
            [name, email, hashedPassword]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);

        // Verifica se o erro é uma violação de chave única (e-mail já existe)
        if (err.code === '23505') {
            return res.status(400).json({ error: 'E-mail já está em uso' });
        }

        res.status(500).json({ error: 'Erro ao registrar usuário' });
    }
});

// Rota para login de usuário
app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        // Verifica se o usuário existe
        const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        const user = result.rows[0];

        if (!user) {
            return res.status(401).json({ error: 'E-mail ou senha incorretos' });
        }

        // Verifica se a senha está correta
        const isMatch = await bcrypt.compare(password, user.password);

        if (isMatch) {
            res.status(200).json({
                message: 'Login bem-sucedido',
                user: {
                    id: user.id,
                    name: user.name,
                    email: user.email,
                }
            });
        } else {
            res.status(401).json({ error: 'E-mail ou senha incorretos' });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Erro ao fazer login' });
    }
});

app.post('/add-to-cart', async (req, res) => {
    const { userName, userEmail, productName, productPrice, quantity, imageUrl } = req.body;

    try {
        // Verifica se o item já existe no carrinho do usuário
        const result = await pool.query(
            'SELECT * FROM cart_items WHERE user_email = $1 AND product_name = $2',
            [userEmail, productName]
        );

        if (result.rows.length > 0) {
            // Atualiza a quantidade do item existente
            await pool.query(
                'UPDATE cart_items SET quantity = quantity + $1 WHERE user_email = $2 AND product_name = $3',
                [quantity, userEmail, productName]
            );
        } else {
            // Adiciona novo item ao carrinho
            await pool.query(
                'INSERT INTO cart_items (user_name, user_email, product_name, product_price, quantity, image_url) VALUES ($1, $2, $3, $4, $5, $6)',
                [userName, userEmail, productName, productPrice, quantity, imageUrl]
            );
        }

        res.status(200).json({ message: 'Item adicionado ao carrinho com sucesso!' });
    } catch (error) {
        console.error('Erro ao adicionar item ao carrinho:', error);
        res.status(500).json({ message: 'Erro ao adicionar item ao carrinho' });
    }
});


app.get('/get-cart-items', async (req, res) => {
    const { userEmail } = req.query;

    try {
        const result = await pool.query(
            'SELECT product_name, product_price, quantity, image_url FROM cart_items WHERE user_email = $1',
            [userEmail]
        );
        res.status(200).json(result.rows);
    } catch (error) {
        console.error('Erro ao buscar itens do carrinho:', error);
        res.status(500).json({ message: 'Erro ao buscar itens do carrinho' });
    }
});

// Atualizar a quantidade do item no carrinho
app.put('/update-cart-item', async (req, res) => {
    const { userEmail, productName, quantity } = req.body;

    try {
        // Atualiza a quantidade do item no carrinho
        await pool.query(
            'UPDATE cart_items SET quantity = $1 WHERE user_email = $2 AND product_name = $3',
            [quantity, userEmail, productName]
        );
        res.status(200).json({ message: 'Quantidade atualizada com sucesso!' });
    } catch (error) {
        console.error('Erro ao atualizar quantidade:', error);
        res.status(500).json({ message: 'Erro ao atualizar quantidade' });
    }
});

app.delete('/remove-from-cart', async (req, res) => {
    const { userEmail, productName } = req.body;

    try {
        const result = await pool.query(
            'DELETE FROM cart_items WHERE user_email = $1 AND product_name = $2',
            [userEmail, productName]
        );

        if (result.rowCount > 0) {
            res.status(200).json({ message: 'Item removido com sucesso!' });
        } else {
            res.status(404).json({ message: 'Item não encontrado para remoção.' });
        }
    } catch (error) {
        console.error('Erro ao remover item do carrinho:', error);
        res.status(500).json({ message: 'Erro ao remover item do carrinho' });
    }
});

app.post('/finalize-purchase', async (req, res) => {
    const { userEmail, userName, cartItems } = req.body;

    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        // Inserir pedidos finalizados
        for (const item of cartItems) {
            await client.query(
                'INSERT INTO pedidos_finalizados (user_name, user_email, product_name, price, quantity, image_url) VALUES ($1, $2, $3, $4, $5, $6)',
                [userName, userEmail, item.name, item.price, item.quantity, item.imageUrl]
            );
        }

        // Remover itens do carrinho
        await client.query(
            'DELETE FROM cart_items WHERE user_email = $1',
            [userEmail]
        );

        await client.query('COMMIT');
        res.status(200).json({ message: 'Compra finalizada com sucesso!' });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Erro ao finalizar compra:', error);
        res.status(500).json({ message: 'Erro ao finalizar compra' });
    } finally {
        client.release();
    }
});

app.get('/get-finalized-orders', async (req, res) => {
    const { userEmail, userName } = req.query;

    try {
        const result = await pool.query(
            'SELECT product_name, price, quantity, created_at, image_url FROM pedidos_finalizados WHERE user_email = $1 AND user_name = $2',
            [userEmail, userName]
        );

        res.json(result.rows);
    } catch (err) {
        console.error('Erro ao buscar pedidos:', err);
        res.status(500).send('Erro ao buscar pedidos');
    }
});

async function getCartItemCount(userEmail) {
    try {
        const result = await pool.query(
            'SELECT SUM(quantity) AS count FROM cart_items WHERE user_email = $1',
            [userEmail]
        );
        const count = result.rows[0].count || 0;
        return parseInt(count, 10); // Assegura que o valor retornado é um número
    } catch (error) {
        console.error('Erro ao buscar quantidade de itens no carrinho:', error);
        throw error;
    }
}

// Rota para obter a quantidade de itens no carrinho
app.get('/get-cart-item-count', async (req, res) => {
    const { userEmail } = req.query;

    try {
        const count = await getCartItemCount(userEmail);
        res.json({ count });
    } catch (error) {
        res.status(500).send('Erro ao buscar quantidade de itens no carrinho');
    }
});
  
  
app.listen(3000, () => {
    console.log('Server running on port 3000');
});
