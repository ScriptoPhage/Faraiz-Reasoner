list(allMembersArray,[father, mother, son,daughter,paternal_Grandfather,paternal_Grandmother,maternal_Grandmother,brother,sister,paternal_Grandson,paternal_Granddaughter,paternal_Sister,paternal_Brother,maternal_Sister,maternal_Brother,male_Paternal_Ancester_Other_Than_Father_and_Grandfather]).
list(mulltipleMembersArray,[son,daughter,brother,sister,paternal_Grandson,paternal_Granddaughter,paternal_Sister,paternal_Brother,maternal_Sister,maternal_Brother]).

consider(husband, 0.5):- here(husband), absent(son), absent(daughter).

consider(husband, 0.25):- (here(son); here(daughter)),here(husband).

consider(wife, 0.25):- here(wife), absent(son), absent(daughter).

consider(wife, 0.125):- (here(son); here(daughter)),here(wife).

consider(daughter, 0.5):- quantity(daughter,1), absent(son).

consider(daughter, 0.666666667):-  quantity(daughter,X),X > 1, absent(son).

consider(paternal_Granddaughter, 0.5):- quantity(paternal_Granddaughter,1), absent(son), absent(daughter), absent(paternal_Grandson).

consider(paternal_Granddaughter, 0.666666667):- quantity(paternal_Granddaughter,X),X>1, absent(son), absent(daughter), absent(paternal_Grandson).

consider(paternal_Granddaughter, 0.166666667):- here(paternal_Granddaughter),quantity(daughter,1) , absent(son), absent(paternal_Grandson).

consider(father, 0.166666667):- (here(son); here(daughter)),here(father).

consider(mother, 0.333333333):- here(mother), absent(son), absent(daughter),numSiblings(G),G<2.

consider(mother, 0.166666667):-  (here(son); here(daughter); (numSiblings(G),G>1)), here(mother).

consider(paternal_Grandfather, 0.166666667):- (here(son); here(daughter)),here(paternal_Grandfather), absent(father).

consider(paternal_Grandmother, 0.166666667):- here(paternal_Grandmother), absent(mother), absent(father), absent(maternal_Grandmother).

consider(paternal_Grandmother, 0.083333333):- here(paternal_Grandmother), absent(mother), absent(father), here(maternal_Grandmother).

consider(maternal_Grandmother, 0.166666667):- here(maternal_Grandmother), absent(mother).

consider(maternal_Grandmother, 0.083333333):- here(maternal_Grandmother), absent(mother), absent(father), here(paternal_Grandmother).

consider(sister, 0.5):-  quantity(sister,1), absent(son), absent(daughter), absent(brother), absent(malePaternalAncestor).

consider(sister, 0.666666667):- quantity(sister,X),X>1, absent(son), absent(daughter), absent(brother), absent(malePaternalAncestor).

consider(paternal_Sister, 0.5):- quantity(paternal_Sister,1) , absent(son), absent(daughter), absent(brother), absent(sister), absent(paternal_Brother), absent(malePaternalAncestor).

consider(paternal_Sister, 0.666666667):- quantity(paternal_Sister,X),X>1 , absent(son), absent(daughter), absent(brother),absent(sister), absent(paternal_Brother), absent(malePaternalAncestor).

consider(paternal_Sister, 0.166666667):- here(paternal_Sister),quantity(sister,1) , absent(son), absent(daughter), absent(brother), absent(paternal_Brother), absent(malePaternalAncestor).

consider(maternal_Sibling, 0.166666667):- quantity(maternal_Sister,A),quantity(maternal_Brother,B),A+B is 1,absent(son),absent(malePaternalAncestor).

consider(maternal_Sibling, 0.333333333):- quantity(maternal_Sister,A),quantity(maternal_Brother,B),A+B > 1,absent(son),absent(malePaternalAncestor).


numSiblings(G):- quantity(sister,A),quantity(brother,B),quantity(maternal_Sister,C),quantity(maternal_Brother,D),quantity(paternal_Sister,E),quantity(paternal_Brother,F),G is (A+B+C+D+E+F).

here(malePaternalAncestor):- here(father);here(paternal_Grandfather);here(male_Paternal_Ancester_Other_Than_Father_and_Grandfather).
absent(malePaternalAncestor):- absent(father),absent(paternal_Grandfather),absent(male_Paternal_Ancester_Other_Than_Father_and_Grandfather).

%Residual Calculation
prescribing:- findall([Person,Share],consider(Person,Share),List),assertz(list(presc_array,List)).

% prescribedShare:-
% findall(Share,consider(_,Share),List),assertz(list(share_array,List)).

resultPrinting([]).
resultPrinting([H|T]) :- write(H),nl, resultPrinting(T).

printResult:-findall([Person,Share],consider(Person,Share),List),sort(List,Newlist),resultPrinting(Newlist).

compAnswer(Person,Ans):- Ans = yes -> (assertz(here(Person))); (assertz(absent(Person))).

compPerson(Person,Quantity):- Quantity > 0 -> (assertz(quantity(Person,Quantity)),assertz(here(Person)));(assertz(quantity(Person,Quantity)),assertz(absent(Person))).

askQuantity(Person, Quantity):-
    write("How many "),write(Person), write("s does the deceased person have alive?"), nl,
    read(Quantity),nl,compPerson(Person,Quantity).
askIfAlive(X, Value):- (list(mulltipleMembersArray,Array),member(X,Array)) -> askQuantity(X,Quantity); (write("Is the deceased person's "), write(X),  write(" alive? (yes/no)"), nl, read(Value),nl,compAnswer(X,Value)).

beginAsking([]).
beginAsking([H|T]) :- askIfAlive(H,Value), beginAsking(T).

output:- list(allMembersArray,Array),beginAsking(Array).

husbandInfo(Ans):- Ans = yes -> (assertz(here(husband))); (assertz(absent(husband))).

wifeInfo(Ans):- Ans = yes -> (assertz(here(wife))); (assertz(absent(wife))).

askGender(X):- write("Is the deceased person Male or Female? Answer(male/female) "),nl,read(X).

askOfSpouse:- (askGender(X),X = male )->(write("Is(Are) his wife(wives) alive? (yes/no)"),nl,read(Ans),wifeInfo(Ans));(write("Is her husband alive? (yes/no)"),nl,read(Ans),husbandInfo(Ans)).

main:- abolish(here/1), abolish(absent/1),abolish(quantity/2),askOfSpouse, output,printResult.
