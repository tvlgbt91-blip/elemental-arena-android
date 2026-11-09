# Elemental Arena — protótipo Android 3D

Projeto fan-made de luta em arena inspirado em Genshin Impact. Este pacote contém um protótipo jogável em Godot 4, com personagens selecionáveis por nome/elemento, câmera em terceira pessoa, arena circular, IA simples, ataque, habilidade elemental, esquiva e botões de toque.

## Importante
- Este é um protótipo inicial: os lutadores são formas 3D temporárias, não modelos oficiais. Modelos, roupas, vozes, músicas e animações oficiais de Genshin Impact são propriedade dos respectivos titulares e não estão incluídos.
- O projeto usa nomes e referências aos personagens para demonstrar a seleção e os elementos. Para uma versão pública/comercial, use conteúdo licenciado ou personagens originais.
- O pacote é o projeto-fonte; não é um APK pronto. A exportação Android precisa do Godot 4 e das ferramentas Android instaladas.

## Abrir no computador
1. Instale Godot 4.3 ou superior.
2. Extraia o ZIP.
3. Abra `project.godot` no Godot.
4. Pressione F6/F5 para executar.

## Exportar para Android
1. No Godot, instale os Export Templates pela opção Editor > Manage Export Templates.
2. Configure o Android SDK/JDK em Editor > Editor Settings > Export > Android.
3. Crie um preset Android em Project > Export.
4. Defina package name, orientação e ícone.
5. Exporte como APK para teste ou AAB para publicação.

## Controles
- PC: WASD, J (ataque), K (habilidade), Espaço (esquiva), Q (trocar personagem).
- Celular: botões na tela para mover, atacar, usar poder, esquivar e trocar personagem.

## Próximas melhorias
- Modelos 3D estilizados e animações de cada personagem.
- Barra de vida, lock-on, combos e efeitos elementais reais.
- Multiplayer local/online e seleção de arenas.
- Ajustes de interface e desempenho em aparelhos Android.

## Gerar APK usando somente o celular (GitHub Actions)
1. Crie uma conta gratuita no GitHub pelo navegador do celular.
2. Crie um repositório novo e envie todos os arquivos desta pasta (incluindo `.github/workflows/build-android.yml`). Ao enviar pelo navegador, habilite a visualização de arquivos ocultos se necessário, para incluir `.github`.
3. Abra a aba **Actions** do repositório. Na primeira utilização, autorize workflows se o GitHub pedir.
4. Selecione **Build Android APK** e toque em **Run workflow**. Aguarde a execução terminar com sucesso.
5. Abra a execução concluída e baixe o artefato **ElementalArena-Android-APK**. Extraia o ZIP e instale o APK no Android, autorizando a instalação pelo navegador/gerenciador de arquivos quando solicitado.

A compilação depende da imagem e dos templates Android disponíveis no ambiente de CI. Se falhar, abra o log da execução e use a mensagem de erro para corrigir a configuração. Este fluxo gera um APK de depuração para testes, não uma versão assinada para publicação na Play Store.
