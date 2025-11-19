DESCRIÇÂO:
Este script cria 2 (duas) Tasks no agendador de tarefas do Windows que têm como objetivo limpar os perfis de usuários e arquivos temporários das pastas públicas.

CONTEXTO:
Uso em laboratórios que fazem parte de um dominío acadêmcio AD e necessitam excluir as contas dos usuários a cada reinicialização.

UTILIZAÇÂO:
1) Edite $excluir para inserir os perfis de usuários que NÂO se deseja excluir;
2) Edite $pastas, caso necessário, para incluir mais pastas que se deseja limpar a cada reinicialização;
3) Rode o comando abaixo no PowerShell como administrador para permitir a execução de scripts:
    Set-ExecutionPolicy Unrestricted
4) No PowerShell, navega até a pasta onde está localizado o script e execute:
    .\Instalar-LimpezaLab.ps1