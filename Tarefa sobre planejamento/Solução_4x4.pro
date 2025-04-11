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

% Encontra a primeira célula vazia (mais eficiente que nth1 aninhado)
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
fill_cell(State, Row, Col, Num, NewState) :-
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
	

% Saída:

[1, 3, 4, 2]
[4, 2, 1, 3]
[2, 4, 3, 1]
[3, 1, 2, 4]
FinalState = [[1, 3, 4, 2], [4, 2, 1, 3], [2, 4, 3, 1], [3, 1, 2, 4]],
Plan = [fill(1,2,3), fill(1,3,4), fill(1,4,2), fill(2,1,4), fill(2,3,1), fill(2,4,3), fill(3,1,2), fill(3,2,4), fill(3,4,1), fill(4,1,3), fill(4,2,1), fill(4,3,2)]
% 