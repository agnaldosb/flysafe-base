# FlySafe para ns-3.38

O conteudo desta pasta segue a mesma estrutura do projeto original em `ns-allinone-3.38/ns-3.38/`. Ou seja, voce deve **substituir ou copiar os arquivos dentro das pastas corretas do ns-3**, e nao copiar a pasta inteira de uma vez para dentro do projeto, porque isso pode criar pastas duplicadas e quebrar a estrutura esperada pelo ns-3.

## Como aplicar os arquivos

Use a tabela abaixo como referencia para copiar os arquivos desta pasta para dentro do seu `ns-3.38`.

| Origem no `FlySafe ns3-38` | Destino no `ns-3.38` | Acao |
| --- | --- | --- |
| `FlySafe ns3-38/scratch/flysafe.cc` | `ns-3.38/scratch/` | Copiar |
| `FlySafe ns3-38/src/flysafe/` | `ns-3.38/src/` | Copiar a pasta inteira |
| `FlySafe ns3-38/src/network/model/node.h` | `ns-3.38/src/network/model/node.h` | Substituir |
| `FlySafe ns3-38/src/network/model/node.cc` | `ns-3.38/src/network/model/node.cc` | Substituir |
| `FlySafe ns3-38/contrib/ns3-ai/` | `ns-3.38/contrib/` | Copiar a pasta inteira, se quiser usar o `ns3-ai` |
| `FlySafe ns3-38/flysafe_traces/` | `ns-3.38/` | Copiar a pasta inteira |

Observacao: mantenha exatamente a mesma estrutura de subpastas. Nao coloque, por exemplo, `src/flysafe` dentro de outra pasta `src` adicional, nem crie `contrib/ns3-ai/ns3-ai` por engano.

## Compilacao do ns-3.38

Depois de copiar os arquivos, entre na pasta `ns-3.38` e rode:

```bash
./ns3 configure --enable-tests
./ns3 build
```

## Como testar a instalacao

Na raiz desta pasta existe o script `run_flysafe.sh`, que foi configurado para rodar apenas **uma simulacao** com **40 nos**.

Ele aceita o parametro `nMalicious`, que indica quantos dos 40 nos seriam maliciosos. No entanto, a implementacao atual do FlySafe esta **sem ataque**, entao esse parametro nao altera o resultado neste momento.

O script pode ser editado depois para automatizar execucoes sequenciais de varias simulacoes. Basta abrir o arquivo e ajustar:

```bash
TOTAL_RUNS=1
SIM_COMMAND="./ns3 run \"scratch/flysafe -nNodes=40 -runMode=R -nMalicious=0\" > result.txt"
```

Para testar, execute:

```bash
./run_flysafe.sh
```

## Ambiente suportado

Esta versao foi organizada para funcionar com:

- `ns-3.38`
- `Ubuntu 22.04`
- `ns3-ai v1.2.0`

O `ns3-ai v1.2.0` foi feito para o `ns-3.38` e permite integrar modelos em `PyTorch`, `TensorFlow` e `Gym`.

## Se voce nao quiser usar o ns3-ai

O `FlySafe` continua funcionando normalmente sem o `ns3-ai`.

Nesse caso, basta **nao copiar a pasta `contrib/ns3-ai/`** para o seu `ns-3.38`.

## Como rodar os scripts de avaliação

A pasta `flysafe_traces/scripts/` contem os scripts que calculam as metricas de avaliacao
do FlySafe, uma por arquivo. O `0_run_all.py` roda todos na ordem certa e escreve as
tabelas em LaTeX ao final.

Rode **de dentro da pasta `scripts/`**:

```bash
cd flysafe_traces/scripts
./0_run_all.py            # os dois cenarios (all e o padrao)
./0_run_all.py bl         # so BASELINE
./0_run_all.py ba         # so BASEATTK
```

Cada metrica tambem roda sozinha, com o mesmo parametro:

```bash
./3_localization_error.py ba
./8_tables.py                 # so regerar as tabelas .tex
```

As pastas dos cenarios ficam ao lado de `scripts/`:

```
flysafe_traces/
├── scripts/
├── BASELINE/     simulacoes sem ataque
└── BASEATTK/     simulacoes com ataque, sem defesa
```

Os resultados vao para `<cenario>/flysafe_global_traces/` e as tabelas para
`flysafe_traces/tables/`.

O `flysafe_traces/scripts/README.md` explica cada metrica, e traz as instrucoes para voce
**adicionar o seu proprio cenario** de solucao e as **suas proprias metricas** ao pipeline.

## Resumo rapido

1. Copie os arquivos para as pastas corretas dentro de `ns-3.38`.
2. Nao duplique a estrutura do projeto ao colar os arquivos.
3. Rode `./ns3 configure --enable-tests` e depois `./ns3 build`.
4. Use `bash run_flysafe.sh` para validar a instalacao.
5. Se nao for usar o `ns3-ai`, pode deixar a pasta `contrib/ns3-ai/` de fora.
6. Para avaliar os resultados, rode `./0_run_all.py` de dentro de `flysafe_traces/scripts/`.
