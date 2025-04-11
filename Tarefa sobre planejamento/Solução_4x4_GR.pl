% Define números 1-4
num(1). num(2). num(3). num(4).

% Predicado principal
plan(InitialState, FinalState, Plan) :-
    is_valid_grid(InitialState),
    copy_term(InitialState, CurrentState),
    solve_sudoku(CurrentState, FinalState, [], RevPlan),
    reverse(RevPlan, Plan).

% Verificação da grade
is_valid_grid(Grid) :-
    length(Grid, 4),
    maplist(is_valid_row, Grid).

is_valid_row(Row) :-
    length(Row, 4),
    maplist(between(0,4), Row).

% Solucionador principal
solve_sudoku(State, State, Plan, Plan).

solve_sudoku(CurrentState, FinalState, PartialPlan, Plan) :-
    find_empty_cell(CurrentState, Row, Col),
    num(Num),
    is_valid(CurrentState, Row, Col, Num),
    fill_cell(CurrentState, Row, Col, Num, NewState),
    solve_sudoku(NewState, FinalState, [fill(Row,Col,Num)|PartialPlan], Plan).

% Encontra célula vazia
find_empty_cell(Grid, Row, Col) :-
    nth1(Row, Grid, RowList),
    nth1(Col, RowList, 0).

% Verifica validade
is_valid(State, Row, Col, Num) :-
    nth1(Row, State, RowList),
    \+ member(Num, RowList),
    column(State, Col, ColumnList),
    \+ member(Num, ColumnList),
    subgrid(State, Row, Col, Subgrid),
    \+ member(Num, Subgrid).

% Operações com a grade
column([], _, []).
column([Row|Rest], Col, [Value|Values]) :-
    nth1(Col, Row, Value),
    column(Rest, Col, Values).

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

fill_cell(State, Row, Col, Num, NewState) :-
    nth1(Row, State, RowList),
    replace(RowList, Col, Num, NewRowList),
    replace(State, Row, NewRowList, NewState).

replace([_|T], 1, X, [X|T]).
replace([H|T], Pos, X, [H|NewT]) :-
    Pos > 1,
    NextPos is Pos - 1,
    replace(T, NextPos, X, NewT).

% Exemplo e impressão CORRIGIDOS
correct_example :-
    Initial = [
        [1, 0, 0, 0],
        [0, 2, 0, 0],
        [0, 0, 3, 0],
        [0, 0, 0, 4]
    ],
    plan(Initial, Final, Plan),
    print_grid(Final),
    writeln('Plano de Ações:'),
    print_plan(Plan).

% IMPRESSÃO CORRIGIDA - Versão robusta
print_grid([R1,R2,R3,R4]) :-
    R1 = [A1,A2,A3,A4],
    R2 = [B1,B2,B3,B4],
    R3 = [C1,C2,C3,C4],
    R4 = [D1,D2,D3,D4],
    format('~n[~w, ~w, ~w, ~w]', [A1,A2,A3,A4]),
    format('~n[~w, ~w, ~w, ~w]', [B1,B2,B3,B4]),
    format('~n[~w, ~w, ~w, ~w]', [C1,C2,C3,C4]),
    format('~n[~w, ~w, ~w, ~w]~n~n', [D1,D2,D3,D4]).

print_plan([]).
print_plan([Action|Actions]) :-
    format('~w~n', [Action]),
    print_plan(Actions).
	
% Entrada: correct_example;