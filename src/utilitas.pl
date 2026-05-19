% ============================================================
% Utilitas List & Tampilan
% ============================================================
 
% ----- Tampilan List -----
 
tampilkan_list([]) :- nl.
tampilkan_list([H]) :- write(H), nl.
tampilkan_list([H|T]) :-
    write(H), write(' - '),
    tampilkan_list(T).
 
% ----- Operasi List -----
 
% Ambil elemen ke-N, kembalikan sisa list
ambil_ke(1, [H|T], H, T) :- !.
ambil_ke(N, [H|T], X, [H|Sisa]) :-
    N > 1,
    N1 is N - 1,
    ambil_ke(N1, T, X, Sisa).
 
% Akses elemen ke-N tanpa mengubah list
nth_element(1, [H|_], H) :- !.
nth_element(N, [_|T], X) :-
    N > 1,
    N1 is N - 1,
    nth_element(N1, T, X).
 
% Hapus elemen ke-N dari list
hapus_ke_n(1, [_|T], T) :- !.
hapus_ke_n(N, [H|T], [H|Sisa]) :-
    N > 1,
    N1 is N - 1,
    hapus_ke_n(N1, T, Sisa).
 
% ----- Tampilan Kartu -----
 
tulis_kartu(kartu(Warna, Jenis)) :-
    write(Warna), write('-'), write(Jenis).
 
tampilkan_kartu_bernomor([], _).
tampilkan_kartu_bernomor([K|T], N) :-
    format('~w. ', [N]),
    tulis_kartu(K), nl,
    N1 is N + 1,
    tampilkan_kartu_bernomor(T, N1).
