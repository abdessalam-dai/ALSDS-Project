unit ExpDeBase;

interface
uses SysUtils;
const
    Nmes = 24; { Nombre total de messages (Tweets) }
    MotsMax = 150; { Maximum nombre de mots dans un message }
    MotsMaxDict = MotsMax*Nmes; { Maximum nombre de mots dans un dictionnaire }
type
    messagesTab = array [1..Nmes] of string; { Type Tableau des messages }
    motsTab = array [1..MotsMax] of string; { Type Tableau des mots }
    dictionnaire = array [1..MotsMaxDict] of string; { Type Tableau d'un dictionnaire des mots }
    message_record = record { Type Enregistrement d'un message }
        original: string;
        nettoye: string;
        nbMots: integer;
        nbMotsSansRep: integer;
        mots: motsTab;
    end;
    tousMsgsTab = array[1..Nmes] of message_record; { Type Tableau des enregistrements des messages }

function AuMinuscule(mot: string): string;
function Nettoyer(msg: string): string;
function NombreDeMot(msg: string): integer;
function ExtractMots(msg: string): motsTab;
procedure SansRepeter(mots: motsTab; var mots_sans_rep: motsTab; nb_mots: integer; var nb_mots_sans_rep: integer);
procedure SansRepDeDict(Dict: dictionnaire; var DictSansRep: dictionnaire; nb_mots_dict: integer);
function Freq(dict: dictionnaire; mot: string; nb_mots_dict: integer): integer;
function AfficherFreq(f: integer; nb_mots_dict: integer): string;
procedure OrdreAlpha(var dict: dictionnaire; nb_mots_dict: integer; ordre: boolean);
procedure OrdreFreq(dict_org: dictionnaire; var dict: dictionnaire; nb_mots_dict: integer; ordre: boolean);
procedure EtudierMessage(var dict: dictionnaire; var nb_mots_dict: integer; indice_de_msg: integer; msg_original: string; var tous_msgs: tousMsgsTab);
procedure EnrigistrerMots(nom: string; dict_org, dict: dictionnaire; nb_mots_dict: integer; detail: boolean);
procedure LireMots(nom: string; nb_mots_dict, nb_limit: integer; croiss: boolean);
function LireDict(nom: string): dictionnaire;
function LireNbMotsDict(nom: string): integer;
procedure ModifierNbMotsDict(nom: string; valeur: integer);
procedure AfficherMotsDict(nom, ordre: string; nb_limit: integer);
procedure ConsulterDict(nom: string);
procedure ConsulterLesDicts();
procedure ExplorerLaBase(msgs_a_explorer: messagesTab; nom: string);

implementation
{
- FONCTION AuMinuscule:
    OBJECTIFS:  - Convertir un mot en minuscules.

    ENTREES:    - Un mot.

    SORTIES:    - Un mot en minuscules.
}
function AuMinuscule(mot: string): string;
    var i: integer;
        c: char;
    begin
        mot := Trim(mot);
        for i := 1 to length(mot) do
            begin
                c := mot[i];
                if (ord(c) >= 65) and (ord(c) <= 90) then
                    begin
                        { Remplacer chaque lettre par sa forme minuscule }
                        mot[i] := chr(ord(c) + 32);
                    end;
            end;
        AuMinuscule := mot;
    end;

{
- FONCTION Nettoyer:
    OBJECTIFS:  - Nettoyer un message, en supprimant
                  les caractères specieux et les chiffres.

    ENTREES:    - Un message.

    SORTIES:    - Un message nettoye.
}
function Nettoyer(msg: string): string;
    var i: integer;
        c, cp: char;
    begin
        for i := 1 to length(msg) do
            begin
                c := msg[i];
                if not(c in ['a'..'z']) and not(c in ['A'..'Z']) then
                    { Remplacer tous les caractères par un espace,
                      sauf pour les caractères alphabetiques }
                    msg[i] := ' '
                else
                    { Converir tous les letters au minuscule }
                    msg[i] := AuMinuscule(c)[1];
            end;
        cp := 'A';
        for i := 1 to length(msg) do
            begin
                c := msg[i];
                if (c = ' ') and (cp = ' ') then
                    begin
                        { Supprimer les espaces successifs }
                        msg[i] := chr(0);
                    end;
                cp := c;
            end;
        msg := Trim(msg); { Supprimer les caractères vides au debut et a la fin }

        Nettoyer := msg;
    end;

{
- FONCTION NombreDeMot:
    OBJECTIFS:  - Calculer le nombre de mots d'un message.

    ENTREES:    - Un message.

    SORTIES:    - Le nombre de mots du message.
}
function NombreDeMot(msg: string): integer;
    var i: integer;
        mot: string;
        c: char;
    begin
        msg := msg + ' '; { Ajouter un espace a la fin
                            pour compter le dernier mot }
        mot := '';
        NombreDeMot := 0;
        for i := 1 to length(msg) do
            begin
                c := msg[i];
                if (c <> ' ') then
                    begin
                        mot := mot + c;
                    end
                else
                    begin
                        { Pour chaque espace trouvee,
                          incrementer le nombre de mots }
                        NombreDeMot := NombreDeMot + 1;
                        mot := '';
                    end;
            end;
    end;

{
- FONCTION ExtractMots:
    OBJECTIFS:  - Extraire les mots d'un message.

    ENTREES:    - Un message.

    SORTIES:    - Un tableau des mots.
}
function ExtractMots(msg: string): motsTab;
    var i, j: integer;
        mot: string;
        c: char;
    begin
        msg := Nettoyer(msg);
        msg := msg + ' ';  { Ajouter un espace a la fin
                             pour compter le dernier mot }
        mot := '';
        j := 1;
        for i := 1 to length(msg) do
            begin
                c := msg[i];
                if (c <> ' ') then
                    begin
                        { Pour chaque caractère different de l'espace,
                          ajouter-le au mot }
                        mot := mot + c;
                    end
                else
                    begin
                        { Pour chaque espace trouvee,
                          ajouter le mot au tableau }
                        ExtractMots[j] := mot;
                        j := j + 1;
                        mot := '';
                    end;
            end;
    end;

{
- PROCEDURE SansRepeter:
    OBJECTIFS:  - Calculer le nombre de mots d'un message
                  sans repetitions et extraire ces mots sans
                  repetitions et sans le dernier mot.

    ENTREES:    - Un tableau des mots de message.
                - Le nombre de mots de message.

    SORTIES:    - Un tableau des mots sans repetitions.
                - Le nombre de mots sans repetitions.
}
procedure SansRepeter(mots: motsTab; var mots_sans_rep: motsTab; nb_mots: integer; var nb_mots_sans_rep: integer);
    var i, j: integer;
        dernierMot: string;
    begin
        { Supprimer tous les repetitions }
        for i := 1 to nb_mots do
            begin
                for j := i+1 to nb_mots do
                    begin
                        if Nettoyer(mots[i]) = Nettoyer(mots[j]) then
                            mots[j] := '';
                    end;
            end;

        { Calculer le nombre de mots,
          sans compter les repetitions }
        mots_sans_rep := mots;
        j := 0;
        nb_mots_sans_rep := 0;
        for i := 1 to nb_mots do
            begin
                j := j + 1;
                if Nettoyer(mots_sans_rep[i]) <> '' then
                    begin
                        nb_mots_sans_rep := nb_mots_sans_rep + 1;
                    end;
            end;

        { Supprimer le dernier mot }
        dernierMot := Nettoyer(mots_sans_rep[j]);
        if (dernierMot = 'negative')
        or (dernierMot = 'positive')
        or (dernierMot = 'neutral') then
            begin
                nb_mots_sans_rep := nb_mots_sans_rep - 1;
                mots_sans_rep[j] := '';
                if Nettoyer(mots_sans_rep[j-1]) = 'extremely' then
                    begin
                        mots_sans_rep[j-1] := '';
                        nb_mots_sans_rep := nb_mots_sans_rep - 1;
                    end;
            end;
    end;

{
- PROCEDURE SansRepDeDict:
    OBJECTIFS:  - Supprimer les repetition dans un dictionnaire.

    ENTREES:    - Un dictionnaire.
                - Le nombre de mots du dictionnaire.

    SORTIES:    - Un dictionnaire sans repetitions.
}
procedure SansRepDeDict(Dict: dictionnaire; var DictSansRep: dictionnaire; nb_mots_dict: integer);
    var i, j: integer;
    begin
        { Supprimer tous les repetitions }
        for i := 1 to nb_mots_dict do
            begin
                for j := i+1 to nb_mots_dict do
                    begin
                        if Nettoyer(Dict[i]) = Nettoyer(Dict[j]) then
                            Dict[j] := ''
                    end;
            end;
        DictSansRep := Dict;
    end;

{
- FONCTION Freq:
    OBJECTIFS:  - Calculer la frequence d'apparition d'un mot.

    ENTREES:    - Un dictionnaire.
                - Un mot.
                - Le nombre de mots du dictionnaire.

    SORTIES:    - La frequence d'apparition de mot.
}
function Freq(dict: dictionnaire; mot: string; nb_mots_dict: integer): integer;
    var i: integer;
    begin
        mot := Nettoyer(mot);
        Freq := 0;
        for i := 1 to nb_mots_dict do
            begin
                if mot = Nettoyer(dict[i]) then
                    Freq := Freq + 1;
            end;
    end;

{
- FONCTION AfficherFreq:
    OBJECTIFS:  - Afficher la frequence d'apparition d'un mot,
                  sous la forme: frequence / nb_total.

    ENTREES:    - La frequence d'apparition du mot.
                - Le nombre de mots du dictionnaire.

    SORTIES:    - frequence / nb_total.
}
function AfficherFreq(f: integer; nb_mots_dict: integer): string;
    var frequence, nb_total: string;
    begin
        Str(f, frequence);
        Str(nb_mots_dict, nb_total);
        AfficherFreq := frequence + '/' + nb_total; { frequence / nb_total }
    end;

{
- PROCEDURE OrdreAlpha:
    OBJECTIFS:  - Ordonner un dictionnaire alphabetiquement.

    ENTREES:    - Un dictionnaire.
                - Le nombre de mots du dictionnaire.
                - Ordre choisi.

    SORTIES:    - Un dictionnaire ordonnes alphabetiquement.
}
procedure OrdreAlpha(var dict: dictionnaire; nb_mots_dict: integer; ordre: boolean);
    var i, j: integer;
        t, motI, motJ: string;
        op: boolean;
    begin
        for i := 1 to nb_mots_dict do
            if dict[i] <> '' then
                begin
                    for j := i to nb_mots_dict do
                        begin
                            motI := dict[i];
                            motJ := dict[j];
                            if (motI <> '') and (motJ <> '') then
                                begin
                                    if ordre then
                                        begin
                                            { Si l'ordre choisi est a 'true',
                                              ordonner: [a-z] }
                                            op := motI > motJ;
                                        end
                                    else
                                        begin
                                            { Si l'ordre choisi est a 'false',
                                              ordonner: [z-a] }
                                            op := motI < motJ;
                                        end;
                                    if op then
                                        begin
                                            t := motI;
                                            dict[i] := motJ;
                                            dict[j] := t;
                                        end;
                                end;
                        end;
                end;
    end;

{
- PROCEDURE OrdreFreq:
    OBJECTIFS:  - Ordonner un dictionnaire par ordre des frequences.

    ENTREES:    - Le dictionnaire original (Avec repetitions).
                - Un dictionnaire (Sans repetitions).
                - Le nombre de mots du dictionnaire.
                - Ordre choisi (a-z ou z-a).

    SORTIES:    - Un dictionnaire ordonnes par ordre des frequences.
}
procedure OrdreFreq(dict_org: dictionnaire; var dict: dictionnaire; nb_mots_dict: integer; ordre: boolean);
    var i, j, freqI, freqJ: integer;
        t, motI, motJ: string;
        op: boolean;
    begin
        for i := 1 to nb_mots_dict do
            begin
                for j := i to nb_mots_dict do
                    begin
                        motI := Nettoyer(dict[i]);
                        motJ := Nettoyer(dict[j]);
                        if (motI <> '') and (motJ <> '') then
                            begin
                                freqI := Freq(dict_org, motI, nb_mots_dict);
                                freqJ := Freq(dict_org, motJ, nb_mots_dict);
                                if ordre then
                                    begin
                                        { Si l'ordre choisi est a 'true',
                                          ordonner par ordre croissant }
                                        op := freqI > freqJ;
                                    end
                                else
                                    begin
                                        { Si l'ordre choisi est a 'false',
                                          ordonner par ordre decroissant }
                                        op := freqI < freqJ;
                                    end;
                                if op then
                                    begin
                                        t := motI;
                                        dict[i] := motJ;
                                        dict[j] := t;
                                    end;
                            end;
                    end;
            end;
    end;

{
- PROCEDURE EtudierMessage:
    OBJECTIFS:  - Enregistrer les mots d'un message dans le dictionnaire.

    ENTREES:    - L'indice de message.
                - Le message.

    SORTIES:    - Enregistrer les informations de message comme enregistrement.
                - Ajouter les mots de message au dictionnaire.
                - Incrementer le nombre de mots du dictionnaire.
}
procedure EtudierMessage(var dict: dictionnaire; var nb_mots_dict: integer; indice_de_msg: integer; msg_original: string; var tous_msgs: tousMsgsTab);
    var msg, mot: string;
        i, j, nb_mots, nb_mots_sans_rep: integer;
        mots, mots_sans_rep: motsTab;
    begin
        msg := Nettoyer(msg_original); { Nettoyer le message }
        nb_mots := NombreDeMot(msg); { Calculer le nombre de mots de message }
        mots := ExtractMots(msg); { Extraire les mots de message }
        SansRepeter(mots, mots_sans_rep,
            nb_mots, nb_mots_sans_rep); { Extraire les mots de message
                                          sans repetitions}

        with tous_msgs[indice_de_msg] do { Enrigistrer les informations
                                           de message comme enregistrement }
            begin
                original := msg_original;
                nettoye := msg;
                nbMots := nb_mots;
                nbMotsSansRep := nb_mots_sans_rep;
                mots := mots_sans_rep;
            end;

        for j := 1 to nb_mots do { Ajouter tous les mots de message au dictionnaire }
            begin
                mot := Nettoyer(mots[j]);
                if (mot <> '') and (mot <> 'negative') and (mot <> 'positive') then
                    begin
                        nb_mots_dict := nb_mots_dict + 1;
                        Dict[nb_mots_dict] := Nettoyer(mots[j]);
                    end;
            end;
    end;

{
- PROCEDURE EnrigistrerMots:
    OBJECTIFS:  - Enregistrer les mots d'un dictionnaire dans
                  un fichier texte.

    ENTREES:    - Le nom de fichier texte.
                - Le dictionnaire original.
                - Le dictionnaire a enregistrer.
                - Le nombre de mots du dictionnaire.
                - Detail (ajouter la frequence ou non).

    SORTIES:    - Les mots de dictionnaire dans le fichier texte.
}
procedure EnrigistrerMots(nom: string; dict_org, dict: dictionnaire; nb_mots_dict: integer; detail: boolean);
    var i: integer;
        Fout: text;
        info: string;

    begin
        assign(Fout, nom);
        Rewrite(Fout);

        for i := 1 to nb_mots_dict do
            begin
                if dict[i] <> '' then
                    begin
                        info := dict[i];
                        if detail then
                        { Si le detail choisi est a 'true',
                          ajouter la frequence de chaque mot }
                            info := info + ' ' + AfficherFreq(
                                        Freq(
                                            dict_org,
                                            dict[i],
                                            nb_mots_dict
                                            ),
                                        nb_mots_dict
                                        );
                        writeln(Fout, info);
                    end;
            end;

        close(Fout);
    end;

{
- PROCEDURE LireMots:
    OBJECTIFS:  - Afficher les mots d'un fichier texte.

    ENTREES:    - Le nom de fichier texte.
                - Le nombre de mots du dictionnaire.
                - Le nombre limite de mots a lire.
                - Ordre choisi.

    SORTIES:    - Afficher les mots du fichier texte.
}
procedure LireMots(nom: string; nb_mots_dict, nb_limit: integer; croiss: boolean);
    var nb_mots, i: integer;
        mots: text;
        mot: string;
        dict: dictionnaire;
    begin
        nb_mots := 0;
        assign(mots, nom);
        reset(mots);

        for i := 1 to nb_mots_dict do
            { Ajouter tous les mots de fichier au dictionnaire }
            begin
                readln(mots, nom);
                mot := nom;
                if mot <> '' then
                    begin
                        nb_mots := nb_mots + 1;
                        dict[i] := mot;
                    end;
            end;

        close(mots);

        if (nb_limit < 0) or (nb_limit > nb_mots) then
            begin
                { Si le nombre limite est superieur a
                  le nombre total des mots ou inferieur a 0,
                  donc le nombre limite est le nombre total.
                  => Par exemple, si on ne sait pas le nombre de mots,
                     on va mètre nb_limit a -1 }
                nb_limit := nb_mots;
            end;

        if croiss then
            { Si croiss est a 'true',
              afficher en ordre croissant }
            begin
                for i := 1 to nb_limit do
                    begin
                        writeln('   ', dict[i]);
                    end;
            end
        else
            begin
            { Si croiss est a 'false',
              afficher en ordre decroissant }
                for i := nb_mots downto (nb_mots - nb_limit + 1) do
                    begin
                       writeln('    ', dict[i]);
                    end;
            end;
    end;

{
- FONCTION LireDict:
    OBJECTIFS:  - Lire les mots d'un fichier texte.

    ENTREES:    - Le nom de fichier texte.

    SORTIES:    - Un dictionnaire des mots.
}
function LireDict(nom: string): dictionnaire;
    var i: integer;
        mots: text;
        mot: string;
    begin
        assign(mots, nom);
        reset(mots);

        for i := 1 to MotsMaxDict do
            begin
                readln(mots, nom);
                mot := nom;
                if mot <> '' then
                    begin
                        LireDict[i] := mot;
                    end;
            end;

        close(mots);
    end;

{
- FONCTION LireNbMotsDict:
    OBJECTIFS:  - Obtenir le nombre de mots d’un dictionnnaire.

    ENTREES:    - Le nom de fichier texte.

    SORTIES:    - Le nombre de mots du dictionnaire.
}
function LireNbMotsDict(nom: string): integer;
    var i, Code: integer;
        nb_mots: text;
        mot: string;
    begin
        assign(nb_mots, nom);
        reset(nb_mots);

        for i := 1 to 1 do
            begin
                readln(nb_mots, nom);
                Val(nom, LireNbMotsDict, Code);
            end;

        close(nb_mots);
    end;

{
- PROCEDURE ModifierNbMotsDict:
    OBJECTIFS:  - Modifier le nombre de mots d’un dictionnnaire.

    ENTREES:    - Le nom de fichier texte.
                - Le nouveau nombre de mots.

    SORTIES:    - Modifier le nombre de mots du dictionnaire.
}
procedure ModifierNbMotsDict(nom: string; valeur: integer);
    var i: integer;
        nb_mots: text;
        mot: string;
    begin
        assign(nb_mots, nom);
        Rewrite(nb_mots);

        for i := 1 to 1 do
            begin
                writeln(nb_mots, valeur);
            end;

        close(nb_mots);
    end;

{
- PROCEDURE AfficherMotsDict:
    OBJECTIFS:  - Afficher les mots d’un dictionnaire.

    ENTREES:    - Le nom de fichier texte.
                - Ordre choisi.
                - Nombre limite a afficher.

    SORTIES:    - Les mots du dictionnaire.
}
procedure AfficherMotsDict(nom, ordre: string; nb_limit: integer);
    var nb_mots_dict: integer;
    begin
        nb_mots_dict := LireNbMotsDict(nom + 'NbMots.txt');

        if ordre = 'freq-croiss' then
            LireMots(nom + 'Freq.txt', nb_mots_dict, nb_limit, true)
        else
            begin
                if ordre = 'freq-decroiss' then
                    LireMots(nom + 'Freq.txt', nb_mots_dict, nb_limit, false)
                else
                    begin
                        if ordre = 'alpha-decroiss' then
                            LireMots(nom + 'Alpha.txt', nb_mots_dict, nb_limit, false)
                        else
                            LireMots(nom + 'Alpha.txt', nb_mots_dict, nb_limit, true)
                    end;
            end;
    end;

{
- PROCEDURE ConsulterDict:
    OBJECTIFS:  - Consulter un dictionnaire.

    ENTREES:    - Le nom de fichier texte.

    SORTIES:    - Donner la main a l’utilisateur pour choisir
                  comment afficher les mots du dictionnaire.
}
procedure ConsulterDict(nom: string);
    var nb_mots_dict, nb_limit, Code: integer;
        nb_limit_str, nb_limit_str_det, ordre: string;
    begin
        nb_mots_dict := LireNbMotsDict(nom + 'NbMots.txt');
        
        writeln;writeln('=> Combien de mots de la base voulez-vous afficher?');writeln;
        writeln('   [1] Tous les mots de la base (', nb_mots_dict, ')');
        writeln('   [2] Un nombre limite');
        writeln;
        writeln('   [99] Appuyez sur Entree pour sauter cette etape');
        writeln;
        write('ASDS:consult> ');
        readln(nb_limit_str);
        nb_limit_str := AuMinuscule(nb_limit_str);
        case nb_limit_str of
            '1': nb_limit := -1;
            '2':
                begin
                    writeln;
                    writeln('=> Entrez un nombre determine de mots a lister:');writeln;
                    write('ASDS:consult> ');
                    readln(nb_limit_str_det);
                    Val(nb_limit_str_det, nb_limit, Code);
                end;
            else nb_limit := 0;
        end;

        writeln;writeln('=> Avec quelle manière voulez-vous afficher les mots de base?');writeln;
        writeln('   [1] Ordre alphabetique, croissant (a-z)');
        writeln('   [2] Ordre alphabetique, decroissant (z-a)');
        writeln('   [3] Ordre des frequences, croissant');
        writeln('   [4] Ordre des frequences, decroissant');
        writeln;
        writeln('   [99] Appuyez sur Entree pour sauter cette etape');
        writeln;
        write('ASDS:consult> ');
        readln(ordre);
        ordre := AuMinuscule(ordre);
        case ordre of
            '1': AfficherMotsDict(nom, 'alpha-croiss', nb_limit);
            '2': AfficherMotsDict(nom, 'alpha-decroiss', nb_limit);
            '3': AfficherMotsDict(nom, 'freq-croiss', nb_limit);
            '4': AfficherMotsDict(nom, 'freq-decroiss', nb_limit);
        end;

    end;

{
- PROCEDURE ConsulterLesDicts:
    OBJECTIFS:  - Choisir le dictionnaire a consulter.

    ENTREES:    

    SORTIES:    - Consultation de dictionnaire choisi.
}
procedure ConsulterLesDicts();
    var quel_dict: string;
    begin
        writeln('   =================================');
        writeln('   || Consulter les dictionnaires ||');
        writeln('   =================================');
        writeln('_________________________________________');writeln;
        writeln('=> Quel dictionnaire voulez-vous consulter?');writeln;
        writeln('   [1] Dictionnaire des mots positives');
        writeln('   [2] Dictionnaire des mots negatives');
        writeln;
        writeln('   [99] Appuyez sur Entree pour revenir au menu principal');
        writeln;
        write('ASDS:consult> ');
        readln(quel_dict);
        quel_dict := AuMinuscule(quel_dict);
        case quel_dict of
            '1': ConsulterDict('DictPositive');
            '2': ConsulterDict('DictNegative');
        end;
    end;
 
{
- PROCEDURE ExplorerLaBase:
    OBJECTIFS:  - Faire l’exploration d’une base de messages.

    ENTREES:    - Le dictionnaire des messages a explorer.
                - Le nom de fichier texte (pour enregistrer les mots).

    SORTIES:    - Enregistrer les mots de  la base dans des fichier text
                  (original, ordre par frequence, ordre alphabetique).
                - Afficher les information de chaque message.
}
procedure ExplorerLaBase(msgs_a_explorer: messagesTab; nom: string);
    var i, j, nb_mots, nb_mots_dict, nb_limit, Code: integer;
        msg_original, msg, mot, msgs_info, ordre, nb_limit_str, nb_limit_str_det: string;
        mots, mots_sans_rep: motsTab;
        Dict, DictSansRep: dictionnaire;
        tous_msgs, tous_msgs_pos, tous_msgs_neg: tousMsgsTab;
    begin
        nb_mots_dict := 0;
        tous_msgs := tous_msgs_pos;
        if nom = 'DictNegative' then
            tous_msgs := tous_msgs_neg;
        for i := 1 to Nmes do
            begin
                msg_original := msgs_a_explorer[i];
                if msg_original <> '' then
                    begin
                        EtudierMessage(Dict, nb_mots_dict, i, msg_original, tous_msgs)
                    end;
            end;

        // Dictionnaire de mots sans repetitions
        SansRepDeDict(Dict, DictSansRep, nb_mots_dict);

        // Enrigistrer tous les mots de dictionnaire dans un fichier texte
        EnrigistrerMots(nom + '.txt', Dict, DictSansRep, nb_mots_dict, false);

        // Enrigistrer tous les mots de dictionnaire ordonnes frequence dans un fichier texte
        OrdreFreq(Dict, DictSansRep, nb_mots_dict, true);
        EnrigistrerMots(nom + 'Freq.txt', Dict, DictSansRep, nb_mots_dict, true);

        // Enrigistrer tous les mots de dictionnaire ordonnes alpha dans un fichier texte
        OrdreAlpha(DictSansRep, nb_mots_dict, true);
        EnrigistrerMots(nom + 'Alpha.txt', Dict, DictSansRep, nb_mots_dict, true);

        writeln;
        writeln('=> Voulez vous afficher les informations de chaque message?');
        writeln;
        writeln('   [1] Oui');
        writeln;
        writeln('   [99] Appuyez sur Entree pour sauter cette etape');
        writeln;
        write('ASDS:train> ');
        readln(msgs_info);
        msgs_info := AuMinuscule(msgs_info);

        case msgs_info of
            '1', 'oui', 'yes':
                begin
                    for i := 1 to Nmes do
                        begin
                            with tous_msgs[i] do
                                begin
                                    // Afficher tous les information d'un message
                                    if nbMots > 0 then
                                        begin
                                            writeln;
                                            writeln('(' , i, ') MESSAGE N" ', i, ' :');writeln;
                                            writeln('   - MESSAGE ORIGINAL: ');
                                            writeln('       ', original);writeln;
                                            writeln('   - MESSAGE NETTOYE: ');
                                            writeln('       ', nettoye);writeln;
                                            writeln('   - NOMBRE DE MOTS: ', nbMots);writeln;
                                            writeln('   - NOMBRE DE MOTS SANS REPETITION ET SANS DERNIER: ', nbMotsSansRep);writeln;
                                            writeln('   - TOUS LES MOTS SANS REPETITION ET SANS DERNIER: ');writeln;
                                            write('    ');
                                            for j := 1 to nbMots do
                                                begin
                                                    if Nettoyer(mots[j]) <> '' then
                                                        write(' [', mots[j], ']');
                                                end;
                                            writeln;writeln;
                                        end;
                                end;
                        end;
                end;
        end;            

        ModifierNbMotsDict(nom + 'NbMots.txt', nb_mots_dict);
        nb_mots_dict := LireNbMotsDict(nom + 'NbMots.txt');
        writeln('___________________________________________');writeln;
        writeln('   Le dictionnaire a ete cree avec succès!');
        writeln('   Il contient ', nb_mots_dict, ' mots.');
        writeln('___________________________________________');writeln;writeln;
        ConsulterDict(nom);
    end;
end.
