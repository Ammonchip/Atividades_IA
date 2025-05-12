can( move( Block, From, To), [clear( Block), clear( To), on( Block, From)]) :-
    block( Block),
    object( To),
    To \== Block,
    object( From),
    From \== To,
    Block \== From.

adds( move(X, From, To), [on(X, To), clear(From)]).

deletes( move(X, From, To), [on(X, From), clear(To)]).

object( X) :-
    place(X)
    ;   
    block(X).

block(a).
block(b).
block(c).
block(d).

place(1).
place(2).
place(3).
place(4).
place(5).
place(6).

impossible( on(X, X), _).

impossible( on(X, Y), Goals) :-
    member( clear(Y), Goals)
    ;   
    member( on( X, Y1), Goals), Y1 \== Y
    ;   
    member( on( X1, Y), Goals), X1 \== X.

impossible( clear(X), Goals) :-
    member(on(_, X), Goals).

plan( State, Goals, []) :-
    satisfied(State, Goals).

plan( State, Goals, Plan) :-
    append(PrePlan,[Action],Plan),
    select( State, Goals, Goal),
    achieves( Action, Goal),
    can( Action, Condition),
    preserves( Action, Goals),
    regress( Goals, Action, RegressedGoals),
    plan( State, RegressedGoals, PrePlan).

satisfied( State, Goals) :-
    delete_all( Goals, State, []).

select( State, Goals, Goal) :-
    member( Goal, Goals).

achieves( Action, Goal) :-
    adds( Action, Goals),
    member( Goal, Goals).

preserves( Action, Goals) :-
    deletes(Action, Relations),
    \+ (member( Goal, Relations), 
      member(Goal, Goals)).

regress( Goals, Action, RegressedGoals) :-
    adds( Action, NewRelations),
    delete_all( Goals, NewRelations, RestGoals),
    can( Action, Condition),
    addnew( Condition, RestGoals, RegressedGoals).

addnew( [], L, L).
addnew( [Goal | _], Goals, _) :-
    impossible( Goal, Goals),
    !,
    fail.

addnew([X | L1], L2, L3) :-
    member(X, L2), !,
    addnew(L1, L2, L3).

addnew([X | L1], L2, [X | L3]) :-
    addnew(L1, L2, L3).

delete_all([], _, []).
delete_all([X | L1], L2, Diff) :-
    member( X, L2), !,
    delete_all( L1, L2, Diff).
delete_all([X | L1], L2, [X | Diff]) :-
    delete_all(L1, L2, Diff).

initial_state([
    on(a, 4),
    on(b, 6),
    on(d, a),
    on(c, 1),
    clear(3),
    clear(5),
    clear(2),
    clear(b),
    clear(c),
	clear(d)
]).

goal_state([
    on(a, c)
]).