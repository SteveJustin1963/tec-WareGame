% Pure Octave implementation of a Text War Game (inspired by tec-WareGame)
% Features: Recurring menu for commands, persistent status display, turn-based gameplay
% Author: Grok (based on provided conceptual model)
% Run this in Octave: save as 'war_game.m' and execute 'war_game'

clear all; clc; close all;

% Game State Structure
% player_army: initial 100, min 0
% enemy_army: initial 100, min 0
% morale: 100% max
% resources: for future expansions, initial 50
% turn: current turn number
% game_over: true if won/lost
% winner: 'player', 'enemy', or ''

function game_state = init_game()
    game_state.player_army = 100;
    game_state.enemy_army = 100;
    game_state.player_morale = 100;
    game_state.enemy_morale = 100;
    game_state.player_resources = 50;
    game_state.enemy_resources = 50;
    game_state.turn = 0;
    game_state.game_over = false;
    game_state.winner = '';
endfunction

function display_status(state)
    printf('\n');
    printf('=====================================\n');
    printf('         TEXT WAR GAME STATUS        \n');
    printf('=====================================\n');
    printf('Turn: %d\n', state.turn);
    printf('Player Army: %d/100 (%.0f%%)\n', state.player_army, (state.player_army / 100) * 100);
    printf('Player Morale: %.0f%%\n', state.player_morale);
    printf('Player Resources: %d\n', state.player_resources);
    printf('\n');
    printf('Enemy Army: %d/100 (%.0f%%)\n', state.enemy_army, (state.enemy_army / 100) * 100);
    printf('Enemy Morale: %.0f%%\n', state.enemy_morale);
    printf('Enemy Resources: %d\n', state.enemy_resources);
    printf('=====================================\n');
    printf('Battlefield: Open Plains | Weather: Clear\n');
    printf('=====================================\n');
endfunction

function display_menu()
    printf('\nChoose your command:\n');
    printf('1. Attack (Deal damage to enemy)\n');
    printf('2. Defend (Boost morale, reduce incoming damage)\n');
    printf('3. Scout (Gather intel, slight resource gain)\n');
    printf('4. Retreat (Reduce losses but lower morale)\n');
    printf('5. Status (View current status again)\n');
    printf('6. Quit (End game)\n');
    printf('Enter choice (1-6): ');
endfunction

function state = process_player_command(state, choice)
    switch choice
        case 1  % Attack
            damage = randi([10, 25]);
            state.enemy_army = max(0, state.enemy_army - damage);
            state.player_morale = min(100, state.player_morale + 5);  % Success boost
            printf('You launch an attack! Enemy loses %d troops.\n', damage);
            
        case 2  % Defend
            state.player_morale = min(100, state.player_morale + 10);
            state.player_resources = min(100, state.player_resources + 5);  % Conserve resources
            printf('You fortify defenses. Morale boosted!\n');
            
        case 3  % Scout
            intel = randi([1, 3]);
            state.player_resources = min(100, state.player_resources + intel * 5);
            printf('Scouting reveals enemy weaknesses. Gained %d resources.\n', intel * 5);
            
        case 4  % Retreat
            state.player_army = max(0, state.player_army - randi([5, 10]));
            state.player_morale = max(0, state.player_morale - 15);
            printf('Strategic retreat. Minor losses, but morale suffers.\n');
            
        case 5  % Status
            display_status(state);
            % No state change
            
        case 6  % Quit
            state.game_over = true;
            state.winner = 'quit';
            printf('Game ended by player.\n');
            return;
            
        otherwise
            printf('Invalid choice. No action taken.\n');
    endswitch
endfunction

function state = enemy_ai_turn(state)
    % Simple AI: Random choice weighted towards attack/defend
    ai_choice = randi([1, 100]);
    if ai_choice <= 50  % Attack
        damage = randi([8, 20]);
        state.player_army = max(0, state.player_army - damage);
        state.enemy_morale = min(100, state.enemy_morale + 3);
        printf('Enemy attacks! You lose %d troops.\n', damage);
    elseif ai_choice <= 80  % Defend
        state.enemy_morale = min(100, state.enemy_morale + 8);
        state.enemy_resources = min(100, state.enemy_resources + 3);
        printf('Enemy strengthens defenses.\n');
    else  % Scout/Retreat (less likely)
        state.enemy_resources = min(100, state.enemy_resources + randi([2, 5]));
        printf('Enemy scouts the field.\n');
    endif
endfunction

function state = resolve_battle(state)
    % Morale decay based on army losses
    state.player_morale = max(0, state.player_morale - (100 - state.player_army) / 20);
    state.enemy_morale = max(0, state.enemy_morale - (100 - state.enemy_army) / 20);
    
    % Resource consumption for actions (simplified)
    state.player_resources = max(0, state.player_resources - randi([2, 5]));
    state.enemy_resources = max(0, state.enemy_resources - randi([1, 4]));
endfunction

function [game_over, winner] = check_end(state)
    if state.player_army <= 0
        game_over = true;
        winner = 'enemy';
    elseif state.enemy_army <= 0
        game_over = true;
        winner = 'player';
    elseif state.player_morale <= 0
        game_over = true;
        winner = 'enemy';
    elseif state.enemy_morale <= 0
        game_over = true;
        winner = 'player';
    else
        game_over = false;
        winner = '';
    endif
endfunction

function show_end_screen(winner)
    if strcmp(winner, 'player')
        printf('\nVICTORY! The enemy forces are routed.\n');
    elseif strcmp(winner, 'enemy')
        printf('\nDEFEAT! Your army is overwhelmed.\n');
    else
        printf('\nGame Over.\n');
    endif
    printf('Thanks for playing Text War Game!\n');
endfunction

% Main Game Loop
function main()
    state = init_game();
    printf('Welcome to Text War Game!\n');
    printf('Command your army to victory in this turn-based battle.\n\n');
    
    while ~state.game_over
        state.turn = state.turn + 1;
        display_status(state);
        display_menu();
        
        choice_str = input('', 's');
        if ~isempty(choice_str)
            choice = str2num(choice_str);
            state = process_player_command(state, choice);
        endif
        
        if state.game_over
            break;
        endif
        
        % Enemy turn
        printf('\n--- Enemy Turn ---\n');
        state = enemy_ai_turn(state);
        state = resolve_battle(state);
        
        [state.game_over, state.winner] = check_end(state);
        
        if state.game_over
            break;
        endif
        
        printf('Press Enter to continue to next turn...\n');
        pause();  % Wait for user input
    endwhile
    
    display_status(state);  % Final status
    show_end_screen(state.winner);
endfunction

% Run the game
main();
