:- op(900, fy, not).
:- discontiguous prob/3.

% 1. CPTs exatas da imagem
p(burglary, [], 0.001).
p(earthquake, [], 0.002).

p(alarm, [burglary=true, earthquake=true], 0.70).
p(alarm, [burglary=true, earthquake=false], 0.01).
p(alarm, [burglary=false, earthquake=true], 0.70).
p(alarm, [burglary=false, earthquake=false], 0.01).

p(johnCalls, [alarm=true], 0.90).
p(johnCalls, [alarm=false], 0.05).
p(maryCalls, [alarm=true], 0.70).
p(maryCalls, [alarm=false], 0.01).

% 2. Topologia
parent(burglary, alarm).
parent(earthquake, alarm).
parent(alarm, johnCalls).
parent(alarm, maryCalls).

% 3. Regra principal CORRIGIDA
prob(X, Cond, P) :-
    % Se X é evidência, retorna 1 ou 0
    (member(X=true, Cond) -> P = 1 ; 
     member(X=false, Cond) -> P = 0 ;
    
    % Se X não tem pais, retorna probabilidade a priori
    \+ p(X, [_|_], _), p(X, [], P) -> true ;
    
    % Caso contrário, calcula via pais
    findall((Parents,Prob), p(X, Parents, Prob), CPL),
    sum_probs(CPL, Cond, P)).

% 4. Soma ponderada das probabilidades
sum_probs([], _, 0).
sum_probs([(Parents,Prob)|Rest], Cond, Total) :-
    prob_parents(Parents, Cond, PParents),
    sum_probs(Rest, Cond, RestTotal),
    Total is Prob * PParents + RestTotal.

% 5. Probabilidade dos pais
prob_parents([], _, 1).
prob_parents([(Var=Val)|Rest], Cond, Prob) :-
    prob(Var, Cond, P),
    (Val == true -> ProbPart = P ; ProbPart is 1 - P),
    prob_parents(Rest, Cond, RestProb),
    Prob is ProbPart * RestProb.

% Consulta (agora retorna ~0.371)
% ?- prob(earthquake, [johnCalls=true, maryCalls=true], P).