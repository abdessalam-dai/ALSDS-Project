unit ApprentissageMachine;

interface
uses SysUtils, ExpDeBase;
var
    msgs_pos, msgs_neg: messagesTab;

procedure EclaterLaBase(nom: string);
function DernierMot(msg: string): string;
procedure MotsDiscriminants();
procedure Apprentissage();

implementation
{
- PROCEDURE EclaterLaBase:
    OBJECTIFS:  - Eclater la base des messages en deux bases (positifs et negatifs).

    ENTREES:    - Le nom de fichier texte.

    SORTIES:    - Les messages positifs dans un dictionnaire.
                - Les messages negatifs dans un dictionnaire.
}
procedure EclaterLaBase(nom: string);
    var
        msgs : text;
        msg, dernier_mot: string;
        i, j: integer;
    begin
        i := 1;
        j := 1;
        assign(msgs, nom);
        reset(msgs);
        while not EOF(msgs) do
            begin
                readln(msgs, nom);
                msg := nom;

                dernier_mot := DernierMot(msg);
                if dernier_mot = 'positive' then
                    begin
                        msgs_pos[i] := msg;
                        i := i + 1;
                    end
                else
                    begin
                        if dernier_mot = 'negative' then
                            begin
                                msgs_neg[j] := msg;
                                j := j + 1;
                            end;
                    end;
            end;
        close(msgs);
    end;

{
- FONCTION DernierMot:
    OBJECTIFS:  - Extraire le dernier mot d’un message.

    ENTREES:    - Le message.

    SORTIES:    - Le dernier mot.
}
function DernierMot(msg: string): string;
    var i, j: integer;
        c: char;
    begin
        msg := Nettoyer(msg);
        DernierMot := '';
        i := length(msg);
        while i > 1 do
            begin
                c := msg[i];
                if (c <> ' ') then
                    begin
                        i := i - 1;
                    end
                else
                    begin
                        for j := i + 1 to length(msg) do
                            begin
                                c := msg[j];
                                DernierMot := DernierMot + c; { A comme sorite le dernier mot d'un message }
                            end;
                        i := 0
                    end;
            end;
        DernierMot := Nettoyer(DernierMot);
    end;

{
- FONCTION DernierMot:
    OBJECTIFS:  - Extraire le dernier mot d’un message.

    ENTREES:    - Le message.

    SORTIES:    - Le dernier mot.
}
procedure MotsDiscriminants();
    var i, j, k, l, nb_mots_dict_pos, nb_mots_dict_neg: integer;
        mot_pos, mot_neg, mot_pos_copy, mot_neg_copy: string;
        uniq: boolean;
        dict_pos, dict_neg,
        dict_pos_uniq, dict_neg_uniq,
        dict_pos_uniq_freq, dict_neg_uniq_freq: dictionnaire;
    begin
        dict_pos := LireDict('DictPositiveFreq.txt');
        dict_neg := LireDict('DictNegativeFreq.txt');

        nb_mots_dict_pos := LireNbMotsDict('DictPositiveNbMots.txt');
        nb_mots_dict_neg := LireNbMotsDict('DictNegativeNbMots.txt');

        k := 1;
        for i := 1 to nb_mots_dict_pos do
            begin
                mot_pos := dict_pos[i];
                mot_pos_copy := copy(mot_pos, 1, pos(' ', mot_pos) - 1);
                if mot_pos_copy <> '' then
                    begin
                        uniq := true;
                        for j := 1 to nb_mots_dict_neg do
                            begin
                                mot_neg := dict_neg[j];
                                mot_neg_copy := copy(mot_neg, 1, pos(' ', mot_neg) - 1);
                                if mot_neg_copy <> '' then
                                    begin
                                        if mot_pos_copy = mot_neg_copy then
                                            uniq := false;
                                    end;
                            end;
                        if uniq then
                            begin
                                dict_pos_uniq[k] := mot_pos_copy;
                                dict_pos_uniq_freq[k] := mot_pos;
                                k := k + 1;
                            end;
                    end;
            end;

        l := 1;
        for i := 1 to nb_mots_dict_neg do
            begin
                mot_neg := dict_neg[i];
                mot_neg_copy := copy(mot_neg, 1, pos(' ', mot_neg) - 1);
                if mot_neg <> '' then
                    begin
                        uniq := true;
                        for j := 1 to nb_mots_dict_pos do
                            begin
                                mot_pos := dict_pos[j];
                                mot_pos_copy := copy(mot_pos, 1, pos(' ', mot_pos) - 1);
                                if mot_pos <> '' then
                                    begin
                                        if mot_neg_copy = mot_pos_copy then
                                            uniq := false;
                                    end;
                            end;
                        if uniq then
                            begin
                                dict_neg_uniq[l] := mot_neg_copy;
                                dict_neg_uniq_freq[l] := mot_neg;
                                l := l + 1;
                            end;
                    end;
            end;

        // Enrigistrer tous les mots de dictionnaire dans les fichiers texte
        EnrigistrerMots('DictPositive.txt', dict_pos, dict_pos_uniq, k, false);
        EnrigistrerMots('DictPositiveFreq.txt', dict_pos, dict_pos_uniq_freq, k, false);
        OrdreAlpha(dict_pos_uniq_freq, k, true);
        EnrigistrerMots('DictPositiveAlpha.txt', dict_pos, dict_pos_uniq_freq, k, false);

        EnrigistrerMots('DictNegative.txt', dict_neg, dict_neg_uniq, l, false);
        EnrigistrerMots('DictNegativeFreq.txt', dict_neg, dict_neg_uniq_freq, l, false);
        OrdreAlpha(dict_neg_uniq_freq, k, true);
        EnrigistrerMots('DictNegativeAlpha.txt', dict_neg, dict_neg_uniq_freq, k, false);
    end;

{
- PROCEDURE Apprentissage:
    OBJECTIFS:  - Faire l’apprentissage machine.

    ENTREES:    

    SORTIES:    - Afficher le dictionnaire des mots positifs et celui des mots negatifs.
}
procedure Apprentissage();
    var i: integer;
    begin
        { Eclater la base }
        writeln('              ==================================');
        writeln('              || Eclater la base des messages ||');
        writeln('              ==================================');
        writeln('________________________________________________________________');writeln;
        writeln('   Veuillez patienter... En train d’eclater la base de messages');
        writeln('   en deux bases (Positive/Negative)...');
        writeln('________________________________________________________________');writeln;writeln;writeln;
        EclaterLaBase('DataText.txt');

        { Explorer la base des message positifs }
        writeln('    ===========================================');
        writeln('    || Explorer la base des message positifs ||');
        writeln('    ===========================================');
        writeln('_____________________________________________________');writeln;
        writeln('   Veuillez patienter... En train d’explorer la base');
        writeln('   des messages positifs...');
        writeln('_____________________________________________________');
        ExplorerLaBase(msgs_pos, 'DictPositive');writeln;writeln;writeln;

        { Explorer la base des message negatifs }
        writeln('    ===========================================');
        writeln('    || Explorer la base des message negatifs ||');
        writeln('    ===========================================');
        writeln('_____________________________________________________');writeln;
        writeln('   Veuillez patienter... En train d’explorer la base');
        writeln('   des messages negatifs...');
        writeln('_____________________________________________________');
        ExplorerLaBase(msgs_neg, 'DictNegative');writeln;writeln;writeln;

        { Trouver les mots discriminants }
        writeln('       ====================================');
        writeln('       || Trouver les mots discriminants ||');
        writeln('       ====================================');
        writeln('______________________________________________________');
        writeln;
        writeln('   Veuillez patienter... En train de trouver les mots');
        writeln('   discriminants de chaque base...');
        writeln('______________________________________________________');
        MotsDiscriminants();writeln;

        { Afficher les mots discriminants positifs }
        writeln('LES MOTS DISCRIMINANTS POSITIFS: ');
        AfficherMotsDict('DictPositive', 'freq-croiss', -1);
        writeln;
        { Afficher les mots discriminants negatifs }
        writeln('LES MOTS DISCRIMINANTS NEGATIFS: ');
        AfficherMotsDict('DictNegative', 'freq-croiss', -1);
    end;

end.