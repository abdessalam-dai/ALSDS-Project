program ProjetASDS;
uses ExpDeBase, ApprentissageMachine, Test;
var cmd: string;
    apprentissage_machine, tester_msg, consulter_dicts, quit: boolean;

procedure MenuCMD(var cmd: string; apprentissage_machine, consulter_dicts, tester_msg: boolean);
    begin
        writeln('__________________________________________________');
        writeln;
        writeln('               =================');
        writeln('               || Projet ASDS ||');
        writeln('               =================');
        writeln;
        writeln('    Cree par: DAI Abdessalam & CHATBI Bilal');
        writeln('__________________________________________________');
        writeln;
        writeln('=> Choisissez une option dans le menu:');
        writeln;
        writeln('   [1] Faire l’apprentissage de la machine');
        writeln('   [2] Tester un message(s)');
        writeln('   [3] Consulter les bases de dictionnaires');
        writeln;
        writeln('   [99] Quitter');
        writeln;
        write('ASDS> ');
        readln(cmd);
        cmd := AuMinuscule(cmd);
        writeln;
    end;

begin
    { Une sort de ligne de commande pour le programme }
    apprentissage_machine := false;
    tester_msg := false;
    consulter_dicts := false;
    quit := false;

    repeat
        MenuCMD(cmd, apprentissage_machine, consulter_dicts, tester_msg);
        case cmd of
            '1':
                begin
                    apprentissage_machine := true;
                    tester_msg := false;
                    consulter_dicts := false;
                end;
            '2':
                begin
                    apprentissage_machine := false;
                    tester_msg := true;
                    consulter_dicts := false;
                end;
            '3':
                begin
                    apprentissage_machine := false;
                    tester_msg := false;
                    consulter_dicts := true;
                end;
            '99':
                begin
                    quit := true;
                end;
            else
                begin
                    apprentissage_machine := false;
                    tester_msg := false;
                    consulter_dicts := false;
                end;
        end;

        if quit then
            begin
                apprentissage_machine := false;
                tester_msg := false;
                consulter_dicts := false;
            end;
    
        if apprentissage_machine then
            Apprentissage();
        if tester_msg then
            TestDeMsg();
        if consulter_dicts then
            ConsulterLesDicts();
    until quit;
end.