hapus_data :-
    retractall(pemain(_)),
    retractall(urutan_pemain(_)),
    retractall(kartu_di_tangan(_, _)),
    retractall(discard_top(_)),
    retractall(giliran_sekarang(_)),
    retractall(deck_kartu(_)),
    retractall(arah_giliran(_)),
    retractall(warna_aktif(_)),
    retractall(efek_pending(_)),
    retractall(pemain_wdf(_)),
    retractall(status_uni(_)).

tampilkan_list([]) :- nl.

tampilkan_list([H]) :-
    write(H), nl.

tampilkan_list([H|T]) :-
    write(H), write(' - '),
    tampilkan_list(T).

ambil_ke(1, [H|T], H, T) :- !.

ambil_ke(N, [H|T], X, [H|Sisa]) :-
    N > 1,
    N1 is N - 1,
    ambil_ke(N1, T, X, Sisa).

nth_element(1, [H|_], H) :- !.

nth_element(N, [_|T], X) :-
    N > 1,
    N1 is N - 1,
    nth_element(N1, T, X).

hapus_ke_n(1, [_|T], T) :- !.

hapus_ke_n(N, [H|T], [H|Sisa]) :-
    N > 1,
    N1 is N - 1,
    hapus_ke_n(N1, T, Sisa).

tulis_kartu(kartu(Warna, Jenis)) :-
    write(Warna), write('-'), write(Jenis).

tampilkan_kartu_bernomor([], _).

tampilkan_kartu_bernomor([K|T], N) :-
    format('~w. ', [N]),
    tulis_kartu(K), nl,
    N1 is N + 1,
    tampilkan_kartu_bernomor(T, N1).