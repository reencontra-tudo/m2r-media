# STATUS — m2r-media
Atualizado: 26/10/2026 15:40
Prioridade no portfólio: A definir (a frente não tem prazo confirmado)
Fase: implementação parcial em pausa — esquema, tipos, eventos e workflow versionado prontos; publicação multi-conta ainda não ativada (registro de 16/09/2026, não verificado hoje)
Objetivo atual: decidir se a Central de Mídia é retomada
Próximo passo exato: o responsável decide se a Central de Mídia é retomada; só se a resposta for "retomar", a sessão prepara a primeira execução supervisionada do workflow
Feito na última sessão:
- 16/09/2026: o workflow passou a emitir os eventos de mídia (gerada, aprovada, publicada, falha de publicação) e a tabela `events` foi adicionada (histórico do Git deste repositório)
- 26/10/2026: STATUS genérico criado para este repositório público
Pendências (em ordem de prioridade):
- Primeira execução supervisionada do workflow e contas das personas: estado NÃO VERIFICADO em 26/10/2026 (último registro: 16/09/2026)
- Conexão real das páginas das personas pendentes no seed (README)
- Decisão em aberto: incluir o Instagram do Backfindr em `default_targets` (migration 0003; README)
Bloqueios / dependências externas:
- Acesso às contas das personas pendentes (README: "pendente de conexão real das páginas")
Decisões recentes (com data):
- 30/08/2026: esquema e eventos aprovados (README)
- 31/08/2026: banco dedicado, separado de qualquer produto (README)
- 26/10/2026: o STATUS deste repositório público é genérico; o detalhe operacional fica fora dele
