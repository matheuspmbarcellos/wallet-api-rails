# Wallet API

<div>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/rails/rails-original-wordmark.svg" alt="Ruby on Rails" width="30"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/postgresql/postgresql-original.svg" alt="PostgreSQL" width="30">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/postman/postman-original.svg" alt="Postman" width="30"/>
</div>


## Descrição

Este projeto é uma API para gerenciar carteiras digitais (Wallets) e cartões de crédito (Cards). O sistema permite que usuários adicionem e removam cartões de crédito, realizem compras e administrem seus limites de crédito de forma dinâmica, sempre respeitando um limite máximo definido. 

As compras são feitas de acordo com a prioridade de vencimento da fatura dos cartões e o crédito disponível na carteira. O sistema também permite o gerenciamento de usuários com autenticação baseada em `bcrypt` e `JWT`.

## Funcionalidades

### Usuários (Users)
- Criação de novos usuários.
- Autenticação de usuários com JWT.
- Cada usuário possui uma carteira única (Wallet) gerada automaticamente no momento de criação do usuário.

### Carteira (Wallet)
- Um usuário pode visualizar os detalhes de sua Wallet, incluindo:
  - **Limite Máximo** (`limit_max`): A soma dos limites dos cartões vinculados à Wallet.
  - **Limite Definido** (`custom_limit`): Limite ajustável pelo usuário, desde que não ultrapasse o limite máximo.
  - **Crédito Disponível** (`credit_available`): Calculado como a diferença entre o limite definido e os gastos pendentes.
- Adicionar e remover cartões.
- Atualização dinâmica do limite e crédito disponível com base nas transações.
  
### Cartões (Cards)
- Cada cartão possui os seguintes atributos:
  - **Número do Cartão** (`number`)
  - **Nome Impresso** (`name_printed`)
  - **Data de Vencimento** (`due_date`)
  - **Mês de Expiração** (`expiration_month`)
  - **Ano de Expiração** (`expiration_year`)
  - **Limite do Cartão** (`card_limit`)
- As compras são realizadas priorizando os cartões com a data de vencimento mais distante ou o menor limite disponível, conforme aplicável.
- Possibilidade de liberar crédito ao pagar a fatura de um cartão específico.

### Compras
- O sistema permite que o usuário realize compras utilizando o saldo de crédito disponível.
- A compra utiliza o cartão com:
  1. Data de vencimento da fatura mais distante.
  2. Menor limite disponível, se a data de vencimento for a mesma.
- O sistema divide a compra entre cartões se necessário.

## Rotas da API

### Login
- `POST /login`: Login de um usuário e obtenção de um token JWT.

### Users
- `GET /users/:id`: Exibe um usuário.
- `POST /users`: Criação de um novo usuário.
- `PUT /users/:id`: Atualiza as informações de um usuário.

### Wallet
- `GET /wallets/:id`: Exibe as informações da Wallet do usuário autenticado.
- `PATCH /wallets/:id/limit`: Atualiza o limite customizado da Wallet.
- `PATCH /wallets/:id/purchase`: Realiza uma compra utilizando os cartões da Wallet.

### Cards
- `GET /wallets/:wallet_id/cards`: Lista todos os cartões da Wallet.
- `GET /wallets/:wallet_id/cards/:card_id`: Exibe um cartão específico da Wallet.
- `POST /wallets/:wallet_id/cards`: Adiciona um novo cartão à Wallet.
- `DELETE /wallets/:wallet_id/cards/:card_id`: Remove um cartão da Wallet.
- `PATCH /wallets/:wallet_id/cards/:card_id/pay`: Libera crédito ao pagar a fatura de um cartão específico.

## Regras de Negócio

1. **Limite Máximo da Carteira**: A soma dos limites de todos os cartões vinculados à Wallet.
2. **Limite Definido**: O usuário pode ajustar o limite da Wallet, desde que não ultrapasse o limite máximo.
3. **Crédito Disponível**: Calculado como o limite definido menos o total de despesas pendentes.
4. **Adição e Remoção de Cartões**: O usuário pode adicionar ou remover cartões a qualquer momento, e o limite máximo será recalculado automaticamente.
5. **Ordem de Prioridade nas Compras**: As compras são feitas utilizando o cartão com a fatura mais distante ou, em caso de empate, o cartão com menor limite disponível.

## Autenticação

A autenticação é feita com `bcrypt` para criptografar senhas e JWT para gerar tokens de autenticação. O token deve ser incluído no header `Authorization` para acessar rotas protegidas.

## Requisitos de Sistema

- Ruby on Rails
- PostgreSQL
- bcrypt para autenticação de usuários
- JWT para autenticação baseada em tokens
- RSpec para testes unitários e de integração

## Instruções de Instalação

1. Clone o repositório:

   ```bash
   git clone https://github.com/matheuspmbarcellos/wallet-api-rails.git
   ```

2. Navegue até o diretório do projeto:

   ```bash
   cd wallet-api-rails
   ```

3. Instale as dependências:

   ```bash
   bundle install
   ```

4. Configure o banco de dados: 

   ```bash
   # após atualizar o username e password no arquivo config/database.yml
   rails db:create
   rails db:migrate
   ```

5. Execute o servidor:

   ```bash
   rails s
   ```

6. Faça as requisições utilizando um cliente HTTP como Postman ou Insomnia.

## Testes

Para rodar os testes, utilize o comando:

```bash
rspec
```
   
## Contribuições

Contribuições são bem-vindas! Para contribuir, siga as etapas abaixo:

1. Faça um fork do repositório.
2. Crie uma branch para a nova feature (`git checkout -b feature/nova-feature`).
3. Commit as mudanças (`git commit -m 'Adiciona nova feature'`).
4. Faça push da branch (`git push origin feature/nova-feature`).
5. Abra um Pull Request.

## Licença

Esse projeto está sob a licença MIT. Veja o arquivo [LICENSE](./LICENSE) para mais detalhes.
```

Esse README inclui uma visão geral do projeto, suas funcionalidades, rotas e instruções de instalação. Pode ser adaptado conforme novas funcionalidades forem adicionadas.