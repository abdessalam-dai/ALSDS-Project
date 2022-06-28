unit Test;
    
interface
uses
    SysUtils, ExpDeBase;

function SensMot(mot: string): string;
procedure TestMsg(msg: string);
procedure TestMsgs(nom: string);
procedure TestDeMsg();
    
implementation
{
- FONCTION SensMot:
    OBJECTIFS:  - Rechercher le sens d’un mot (positif/negatif/neutre).

    ENTREES:    - Le mot.

    SORTIES:    - Le sens du mot.
}
function SensMot(mot: string): string;
    var dict_pos, dict_neg: dictionnaire;
        i, dict_pos_nb_mots, dict_neg_nb_mots: integer;
        trouv, positive, negative: boolean;
        mot_dict: string;
    begin
        dict_pos := LireDict('DictPositive.txt');
        dict_neg := LireDict('DictNegative.txt');

        dict_pos_nb_mots := LireNbMotsDict('DictPositiveNbMots.txt');
        dict_neg_nb_mots := LireNbMotsDict('DictNegativeNbMots.txt');

        i := 1;
        trouv := false;
        positive := false;
        negative := false;
        while not(trouv) and (i < dict_pos_nb_mots) do
            begin
                mot_dict := dict_pos[i];
                if mot = mot_dict then
                    begin
                        trouv := true;
                        positive := true;
                        SensMot := 'positive';
                    end;
                i := i + 1;
            end;

        if not(positive) then
            begin
                i := 1;
                trouv := false;
                while not(trouv) and (i < dict_neg_nb_mots) do
                    begin
                        mot_dict := dict_neg[i];
                        if mot = mot_dict then
                            begin
                                trouv := true;
                                negative := true;
                                SensMot := 'negative';
                            end;
                        i := i + 1;
                    end;
            end;

        if not(positive) and not(negative) then
            SensMot := 'neutre';
    end;

{
- PROCEDURE TestMsg:
    OBJECTIFS:  - Tester un message (positif/negatif/neutre).

    ENTREES:    - Le message.

    SORTIES:    - Le sens du message.
}
procedure TestMsg(msg: string);
    var i, nb_mots, nb_mots_sans_rep, som: integer;
        mot, indication: string;
        mots, mots_sans_rep: motsTab;
    begin
        msg := Nettoyer(msg);
        nb_mots := NombreDeMot(msg);
        mots := ExtractMots(msg);
        SansRepeter(mots, mots_sans_rep, nb_mots, nb_mots_sans_rep);

        som := 0;
        for i := 1 to nb_mots do
            begin
                mot := mots_sans_rep[i];
                if mot <> '' then
                    begin
                        indication := SensMot(mot);
                        writeln('       ', mot, ' : ', indication);
                        if indication = 'positive' then
                            som := som + 1
                        else
                            begin
                                if indication = 'negative' then
                                    som := som - 1;
                            end;
                    end;
            end;

        writeln;
        if som = 0 then
            writeln('RESULTAT: Ce message est neutre. (', som, ')')
        else
            begin
                if som > 0 then
                    writeln('RESULTAT: Ce message est positif. (', som, ')')
                else
                    writeln('RESULTAT: Ce message est negatif. (', som, ')');
            end;
        writeln;
    end;

{
- PROCEDURE TestMsgs:
    OBJECTIFS:  - Tester des message depuis un fichier texte.

    ENTREES:    - Le nom de fichier texte.

    SORTIES:    - Le sens de chaque message.
}
procedure TestMsgs(nom: string);
    var i, j: integer;
        msg: string;
        msgs: text;
        messages: messagesTab;
    begin
        i := 0;
        assign(msgs, nom);
        reset(msgs);
        while not EOF(msgs) do
            begin
                i := i + 1;
                readln(msgs, messages[i]);
            end;
        close(msgs);

        for j := 1 to i do
            begin
                msg := messages[j];
                writeln('(' , j, ') MESSAGE N" ', j, ' :');
                writeln('   - MESSAGE ORIGINAL: ');
                writeln('       ', msg);writeln;
                writeln('   - TOUS CES MOTS SANS REPETITION:');
                TestMsg(msg);
            end;
    end;        

{
- PROCEDURE TestDeMsg:
    OBJECTIFS:  - Donner la main a l'utilisateur pour
                  tester un ou beaucoup de messages.

    ENTREES:    

    SORTIES:    - Le sens de(s) message(s).
}
procedure TestDeMsg();
    var option, option2, nom, msg: string;
    begin
        writeln('    ==========================');
        writeln('    || Tester un message(s) ||');
        writeln('    ==========================');writeln;
        writeln('_________________________________________________________');writeln;
        writeln('=> Choisissez une option dans le menu:');writeln;
        writeln('   [1] Tester un seul message');
        writeln('   [2] Tester des messages dans un fichier texte');
        writeln;
        writeln('   [99] Appuyez sur Entree pour revenir au menu principal');
        writeln;
        write('ASDS:test> ');
        readln(option);writeln;
        case option of
            '1':
                begin
                    writeln('=> Entrez un message a tester: ');writeln;
                    write('ASDS:test:message> ');
                    readln(msg);writeln;
                    TestMsg(msg);
                end;
            '2':
                begin
                    writeln('=> Quel fichier texte voulez-vous utiliser:');writeln;
                    writeln('   [1] Utiliser le fichier texte par defaut (DataTest.txt)');
                    writeln('   [2] Utiliser un autre fichier texte');
                    writeln;
                    write('ASDS:test:messages> ');
                    readln(option2);writeln;
                    case option2 of
                        '2':
                            begin
                                write('ASDS:test:filename> ');
                                readln(nom);writeln;

                                if FileExists(nom) then
                                    TestMsgs(nom)
                                else
                                    writeln('Le fichier texte n’existe pas!');
                            end;
                        else TestMsgs('DataTest.txt');
                    end;
                end;
        end;
    end;
end.