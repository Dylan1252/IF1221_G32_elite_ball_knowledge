% ============================================================
%  UNI GAME - Save & Load Game
%  IF1221 Logika Komputasional
%  Implementasi saveGame dan loadGame
% ============================================================

% ============================================================
%  HELPER: Konversi atom ke string dan sebaliknya
% ============================================================

% Menulis list kartu dalam format: [warna-jenis,warna-jenis,...]
tulis_list_kartu_file(Stream, []).
tulis_list_kartu_file(Stream, [kartu(W,J)]) :-
    write(Stream, W), write(Stream, '-'), write(Stream, J).
tulis_list_kartu_file(Stream, [kartu(W,J)|T]) :-
    T \= [],
    write(Stream, W), write(Stream, '-'), write(Stream, J),
    write(Stream, ','),
    tulis_list_kartu_file(Stream, T).

% Menulis list pemain dalam format: [p1,p2,p3]
tulis_list_pemain_file(Stream, []).
tulis_list_pemain_file(Stream, [P]) :-
    write(Stream, P).
tulis_list_pemain_file(Stream, [P|T]) :-
    T \= [],
    write(Stream, P), write(Stream, ','),
    tulis_list_pemain_file(Stream, T).

% Menulis list status UNI dalam format: [p1,p2]
kumpulkan_status_uni([], []).
kumpulkan_status_uni([P|Rest], [P|UniRest]) :-
    status_uni(P), !,
    kumpulkan_status_uni(Rest, UniRest).
kumpulkan_status_uni([_|Rest], UniRest) :-
    kumpulkan_status_uni(Rest, UniRest).

% ============================================================
%  SAVE GAME
% ============================================================

saveGame :-
    write('Masukkan nama file penyimpanan: '),
    read(NamaFile),
    atom_concat(NamaFile, '.txt', NamaFileTxt),
    ( open(NamaFileTxt, write, Stream)
        ->  simpan_ke_stream(Stream),
            close(Stream),
            format('Status permainan berhasil disimpan ke ~w.~n', [NamaFileTxt])
        ;   format('Gagal membuka file ~w untuk ditulis.~n', [NamaFileTxt])
    ).

simpan_ke_stream(Stream) :-
    % Tulis urutan pemain
    urutan_pemain(Urutan),
    write(Stream, 'urutan_pemain:['),
    tulis_list_pemain_file(Stream, Urutan),
    write(Stream, ']'), nl(Stream),

    % Tulis giliran sekarang
    giliran_sekarang(Giliran),
    write(Stream, 'giliran:'),
    write(Stream, Giliran), nl(Stream),

    % Tulis discard top
    discard_top(kartu(WD, JD)),
    write(Stream, 'discard_top:'),
    write(Stream, WD), write(Stream, '-'), write(Stream, JD), nl(Stream),

    % Tulis kartu setiap pemain
    simpan_kartu_semua_pemain(Stream, Urutan),

    % Tulis arah permainan
    arah_giliran(Arah),
    write(Stream, 'arah_permainan:'), write(Stream, Arah), nl(Stream),

    % Tulis warna aktif
    warna_aktif(WA),
    write(Stream, 'warna_aktif:'), write(Stream, WA), nl(Stream),

    % Tulis status UNI
    kumpulkan_status_uni(Urutan, UniList),
    write(Stream, 'status_UNI:['),
    tulis_list_pemain_file(Stream, UniList),
    write(Stream, ']'), nl(Stream).

simpan_kartu_semua_pemain(_, []).
simpan_kartu_semua_pemain(Stream, [P|Rest]) :-
    kartu_di_tangan(P, Kartu),
    write(Stream, 'kartu_'), write(Stream, P), write(Stream, ':['),
    tulis_list_kartu_file(Stream, Kartu),
    write(Stream, ']'), nl(Stream),
    simpan_kartu_semua_pemain(Stream, Rest).

% ============================================================
%  LOAD GAME
% ============================================================

loadGame :-
    write('Masukkan nama file yang akan dimuat: '),
    read(NamaFile),
    atom_concat(NamaFile, '.txt', NamaFileTxt),
    ( exists_file(NamaFileTxt)
        ->  hapus_data,
            muat_dari_file(NamaFileTxt),
            giliran_sekarang(Giliran),
            format('Status permainan berhasil dimuat dari ~w.~n', [NamaFileTxt]),
            format('Melanjutkan giliran ~w.~n', [Giliran])
        ;   format('File ~w tidak ditemukan.~n', [NamaFileTxt])
    ).

muat_dari_file(NamaFile) :-
    open(NamaFile, read, Stream),
    baca_semua_baris(Stream, Baris),
    close(Stream),
    proses_semua_baris(Baris).

baca_semua_baris(Stream, []) :-
    at_end_of_stream(Stream), !.
baca_semua_baris(Stream, [Baris|Rest]) :-
    read_term(Stream, Baris, []),
    baca_semua_baris(Stream, Rest).

% ============================================================
%  PARSING BARIS FILE
% ============================================================

proses_semua_baris([]).
proses_semua_baris([Baris|Rest]) :-
    ( proses_baris(Baris) -> true ; true ),
    proses_semua_baris(Rest).

% Format term: urutan_pemain:[p1,p2,...]
proses_baris(urutan_pemain:ListAtom) :-
    !,
    konversi_list_atom_ke_pemain(ListAtom, ListPemain),
    assertz(urutan_pemain(ListPemain)).

% Format term: giliran:nama
proses_baris(giliran:Nama) :-
    !,
    assertz(giliran_sekarang(Nama)).

% Format term: discard_top:warna-jenis
proses_baris(discard_top:WJ) :-
    !,
    parse_kartu_atom(WJ, Kartu),
    assertz(discard_top(Kartu)).

% Format term: arah_permainan:arah
proses_baris(arah_permainan:Arah) :-
    !,
    assertz(arah_giliran(Arah)).

% Format term: warna_aktif:warna
proses_baris(warna_aktif:Warna) :-
    !,
    assertz(warna_aktif(Warna)).

% Format term: status_UNI:[p1,p2,...]
proses_baris(status_UNI:ListAtom) :-
    !,
    konversi_list_atom_ke_pemain(ListAtom, ListUNI),
    assertz_status_uni(ListUNI).

% Format term: kartu_NamaPemain:[kartu1,kartu2,...]
proses_baris(Term) :-
    Term =.. [KunciKartu, ListKartuAtom],
    atom_concat('kartu_', NamaPemain, KunciKartu),
    !,
    konversi_list_atom_ke_kartu(ListKartuAtom, ListKartu),
    assertz(kartu_di_tangan(NamaPemain, ListKartu)).

assertz_status_uni([]).
assertz_status_uni([P|Rest]) :-
    assertz(status_uni(P)),
    assertz_status_uni(Rest).

% ============================================================
%  KONVERSI LIST ATOM (dari notasi [...])
% ============================================================

% List Prolog sudah otomatis di-parse oleh read_term sebagai list
konversi_list_atom_ke_pemain([], []).
konversi_list_atom_ke_pemain([H|T], [H|Rest]) :-
    konversi_list_atom_ke_pemain(T, Rest).

konversi_list_atom_ke_kartu([], []).
konversi_list_atom_ke_kartu([KartuAtom|T], [Kartu|Rest]) :-
    parse_kartu_atom(KartuAtom, Kartu),
    konversi_list_atom_ke_kartu(T, Rest).

% Parse atom seperti 'merah-5', 'hitam-wild_draw_four', dst.
parse_kartu_atom(Atom, kartu(Warna, Jenis)) :-
    atom_string(Atom, Str),
    split_string(Str, "-", "", Parts),
    Parts = [WStr | JenisParts],
    atomic_list_concat(JenisParts, '-', JenisAtom),
    atom_string(Warna, WStr),
    atom_string(Jenis, JenisAtom).

% ============================================================
%  HAPUS DATA (untuk reset state sebelum load)
% ============================================================
% Diasumsikan hapus_data/0 sudah didefinisikan di main.pl:
% hapus_data :-
%     retractall(urutan_pemain(_)),
%     retractall(giliran_sekarang(_)),
%     retractall(kartu_di_tangan(_, _)),
%     retractall(discard_top(_)),
%     retractall(deck_kartu(_)),
%     retractall(arah_giliran(_)),
%     retractall(warna_aktif(_)),
%     retractall(status_uni(_)),
%     retractall(efek_pending(_)),
%     retractall(pemain_wdf(_)).
