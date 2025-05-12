# Inteligência Artificial – Atividade sobre Planejamento

## Alunos:

*Aline da Conceição Ferreira Lima*
*Matheus Rocha Canto*
*João Victor Félix Guedes*
*Karen Letícia Santana da Silva*
*Hannah Lisboa Barreto*
*Paulo Vitor de Castro Freitas*

---

## Objetivo geral da atividade

Analisar um código (que não está funcionando) em Prolog para planejamento.

---

## 1. Explicação: Por que o código não funciona

O código Prolog proposto tem como objetivo preencher uma grade 4x4, seguindo as regras do Sudoku 2x2. Porém, ele apresenta diversos erros que impedem sua execução correta:

- Erro de sintaxe em expressões aritméticas:  
  As expressões ((Row 1) // 2) e ((Col 1) // 2) estão incorretas. O correto é:  
  ((Row - 1) // 2) e ((Col - 1) // 2)

- Erro de sintaxe em `replace/4`:  
  O trecho NextPos is Pos 1 deve ser substituído por:  
  NextPos is Pos - 1

- Ordem reversa do plano:  
  A construção do plano usa [Action | PartialPlan], o que resulta em ordem invertida. Recomenda-se usar:  
  append(PartialPlan, [Action], NewPartialPlan)

- Uso desnecessário de `copy_term/2`:  
  Pode ser removido sem prejuízo funcional.

- Ausência de tratamento para casos inválidos:  
  O código não lida com grids inconsistentes ou já completos, podendo falhar ou entrar em laços infinitos.

- Dependência de um `FinalState` totalmente instanciado:  
  Se não estiver completo, o caso base não será alcançado.

- Falta de verificação de validade no `InitialState`:  
  O algoritmo pode tentar resolver estados impossíveis.

---

## 2. Alterações para funcionar corretamente

- Corrigir expressões aritméticas em subgrid/3:
  - De ((Row 1) // 2) para ((Row - 1) // 2)
  - De ((Col 1) // 2) para ((Col - 1) // 2)

- Corrigir decremento de índice em replace/4:
  - De NextPos is Pos 1 para NextPos is Pos - 1

- Usar append/3 para manter ordem correta do plano:
  - De [Action | PartialPlan] para append(PartialPlan, [Action], NewPartialPlan)

- Remover uso desnecessário de copy_term/2 em plan/3

- Garantir FinalState completamente instanciado na consulta

- Validar o InitialState para garantir que siga as regras do Sudoku

---

## 3. Código corrigido e funcional em Prolog

```prolog
% Define números 1-4
num(1). num(2). num(3). num(4).

% Predicado principal otimizado
plan(InitialState, FinalState, Plan) :-
    valid_grid(InitialState),  % Verificação inicial
    copy_term(InitialState, CurrentState),
    plan_step(CurrentState, FinalState, [], RevPlan),
    reverse(RevPlan, Plan).  % Corrige a ordem do plano

% Caso base: estado final alcançado
plan_step(State, State, Plan, Plan).

% Caso recursivo otimizado
plan_step(CurrentState, FinalState, PartialPlan, Plan) :-
    find_first_empty(CurrentState, Row, Col), !,  % Corte para eficiência
    between(1, 4, Num),  % Geração controlada de números
    is_valid(CurrentState, Row, Col, Num),
    fill_cell(CurrentState, Row, Col, Num, NewState),
    plan_step(NewState, FinalState, [fill(Row,Col,Num)|PartialPlan], Plan).

% Encontra a primeira célula vazia
find_first_empty(Grid, Row, Col) :-
    nth1(Row, Grid, RowList),
    nth1(Col, RowList, 0).

% Verifica se o grid inicial é válido
valid_grid(Grid) :-
    length(Grid, 4),
    maplist(valid_row, Grid).

valid_row(Row) :-
    length(Row, 4),
    maplist(between(0,4), Row).  % 0 representa vazio

% Verificação de validade otimizada
is_valid(State, Row, Col, Num) :-
    nth1(Row, State, RowList),
    \+ member(Num, RowList),
    column(State, Col, ColumnList),
    \+ member(Num, ColumnList),
    subgrid(State, Row, Col, Subgrid),
    \+ member(Num, Subgrid).

% Extração de coluna
column([], _, []).
column([Row|Rest], Col, [Value|Values]) :-
    nth1(Col, Row, Value),
    column(Rest, Col, Values).

% Subgrid 2x2 corretamente implementado
subgrid(State, Row, Col, Subgrid) :-
    SubRow is ((Row-1) // 2) * 2 + 1,
    SubCol is ((Col-1) // 2) * 2 + 1,
    NextRow is SubRow + 1,
    NextCol is SubCol + 1,
    nth1(SubRow, State, Row1),
    nth1(NextRow, State, Row2),
    nth1(SubCol, Row1, A), nth1(NextCol, Row1, B),
    nth1(SubCol, Row2, C), nth1(NextCol, Row2, D),
    Subgrid = [A, B, C, D].

% Preenchimento de célula
fill_cell(State,
Row, Col, Num, NewState) :-
    nth1(Row, State, RowList),
    replace(RowList, Col, Num, NewRowList),
    replace(State, Row, NewRowList, NewState).

% Substituição em lista
replace([_|T], 1, X, [X|T]).
replace([H|T], Pos, X, [H|NewT]) :-
    Pos > 1,
    NextPos is Pos - 1,
    replace(T, NextPos, X, NewT).

% Exemplo de uso
example_solution(FinalState, Plan) :-
    InitialState = [
        [1, 0, 0, 0],
        [0, 2, 0, 0],
        [0, 0, 3, 0],
        [0, 0, 0, 4]
    ],
    plan(InitialState, FinalState, Plan).

% Impressão formatada robusta
print_grid(Grid) :-
    forall(member(Row, Grid),
           (write('['),
            format_row(Row),
            writeln(']'))).

format_row([A,B,C,D]) :-
    format('~w, ~w, ~w, ~w', [A,B,C,D]).

```

## 4. Goal Regression e Diferença para Means-Ends

### Goal Regression

Goal regression é uma técnica de planejamento retrógrado utilizada em inteligência artificial, especialmente no contexto de planejamento baseado em estados. O método parte do estado final desejado (objetivo) e tenta regressivamente encontrar as ações que poderiam ter levado a esse estado a partir do estado inicial.

O planejamento por goal regression segue os seguintes passos:

1. Identifica o objetivo a ser alcançado.
2. Busca ações cujo efeito possa satisfazer esse objetivo.
3. Para cada ação candidata, determina as pré-condições que precisam ser verdadeiras para que a ação seja executável.
4. Adiciona essas pré-condições como novos sub-objetivos.
5. Repete o processo até que todas as pré-condições possam ser satisfeitas no estado inicial.

Esse método é útil em domínios com muitos estados possíveis, pois evita explorar todos os caminhos a partir do estado inicial.

---

### Means-Ends Analysis

Means-Ends Analysis (MEA) é uma técnica heurística de resolução de problemas que combina raciocínio progressivo e regressivo. O método envolve a comparação do estado atual com o objetivo e a escolha de uma ação que reduz a diferença entre eles.

Etapas básicas do MEA:

1. Avalia a diferença entre o estado atual e o objetivo.
2. Escolhe uma ação que possa reduzir essa diferença.
3. Estabelece subobjetivos para que a ação escolhida possa ser realizada (se necessário).
4. Repete o processo até que o objetivo seja alcançado.

---

### Diferenças Principais

| Aspecto                    | Goal Regression                         | Means-Ends Analysis                          |
|----------------------------|------------------------------------------|----------------------------------------------|
| Direção do planejamento    | De trás para frente (regressivo)         | Misto (avalia diferenças e propõe soluções)  |
| Foco                       | Pré-condições das ações                  | Diferença entre estado atual e objetivo       |
| Estratégia de busca        | Busca encadeada reversa                 | Heurística orientada à meta                   |
| Aplicação                  | Planejamento formal, lógicas de ação     | Resolução de problemas em IA geral            |
| Subobjetivos               | Derivados das pré-condições             | Derivados das ações que reduzem a diferença   |

---
## 5. Implementar goal regression
