const jsonServer = require('json-server');
const server = jsonServer.create();
const router = jsonServer.router('db.json'); // Seu arquivo de dados
const middlewares = jsonServer.defaults();

const port = process.env.PORT || 3000; // O Render exige ler a porta do process.env

server.use(middlewares);
server.use(router);

server.listen(port, () => {
    console.log(`JSON Server está rodando na porta ${port}`);
});