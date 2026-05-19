% ============================================================
%  URUTAN & GILIRAN
% ============================================================

next_circular(X, List, Next) :-

    (
        append(_, [X, Next|_], List)

        -> true

        ;

        (
            last(List, X),
            List = [Next|_]
        )
    ).

prev_circular(X, List, Prev) :-

    reverse(List, Rev),

    next_circular(X, Rev, Prev).

pemain_berikutnya(Berikutnya) :-

    giliran_sekarang(Sekarang),

    urutan_pemain(Urutan),

    arah_giliran(Arah),

    (
        Arah = kanan

        ->

        next_circular(
            Sekarang,
            Urutan,
            Berikutnya
        )

        ;

        prev_circular(
            Sekarang,
            Urutan,
            Berikutnya
        )
    ).

% ============================================================
%  PINDAH GILIRAN
% ============================================================

pindah_giliran :-

    giliran_sekarang(Sekarang),

    pemain_berikutnya(Berikutnya),

    retract(giliran_sekarang(Sekarang)),

    assertz(giliran_sekarang(Berikutnya)),

    write('Giliran '),
    write(Berikutnya),
    write('.'), nl.

% ============================================================
%  SKIP TURN
% ============================================================

pindah_giliran_skip :-

    giliran_sekarang(Sekarang),

    pemain_berikutnya(Dilewati),

    urutan_pemain(Urutan),

    arah_giliran(Arah),

    (
        Arah = kanan

        ->

        next_circular(
            Dilewati,
            Urutan,
            Berikutnya
        )

        ;

        prev_circular(
            Dilewati,
            Urutan,
            Berikutnya
        )
    ),

    retract(giliran_sekarang(Sekarang)),

    assertz(giliran_sekarang(Berikutnya)),

    write('Pemain berikutnya kehilangan giliran.'), nl,

    write('Giliran '),
    write(Berikutnya),
    write('.'), nl.