# 📦 Instruções Git

## Repositório Remoto Configurado

O repositório remoto já está configurado:
```
git@github.com:douglashsabreu/PetStop_mobile_2025.git
```

## 🚀 Fazer Push para o GitHub

Execute os seguintes comandos para enviar o código para o GitHub:

```bash
cd petstop
git push -u origin main
```

Se o repositório ainda não existir no GitHub, você precisará:

1. Criar o repositório no GitHub:
   - Acesse: https://github.com/new
   - Nome: `PetStop_mobile_2025`
   - Visibilidade: Público ou Privado (conforme necessário)
   - **NÃO** inicialize com README, .gitignore ou license (já temos)

2. Depois execute:
```bash
git push -u origin main
```

## 📝 Comandos Git Úteis

### Verificar status:
```bash
git status
```

### Adicionar arquivos:
```bash
git add .
```

### Fazer commit:
```bash
git commit -m "Descrição das mudanças"
```

### Ver histórico:
```bash
git log
```

### Verificar remote:
```bash
git remote -v
```

### Atualizar do remoto:
```bash
git pull origin main
```

## 🔄 Workflow Recomendado

1. Fazer alterações no código
2. Verificar o que mudou: `git status`
3. Adicionar arquivos: `git add .`
4. Fazer commit: `git commit -m "Descrição"`
5. Enviar para GitHub: `git push origin main`

---

**Nota:** Certifique-se de ter configurado suas credenciais Git antes de fazer push.

