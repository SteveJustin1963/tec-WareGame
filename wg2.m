 
% Text War Game with ASCII Map and Movement
% Features: 5x5 grid map, movement (N,S,E,W), proximity-based attack, recurring menu, status
% Run in Octave: save as 'war_game.m' and execute 'war_game'

clear all; clc; close all;

% Game State Structure
% player_army, enemy_army: initial 100, min 0
% player_morale, enemy_morale: 100% max
% player_resources, enemy_resources: initial 50
% player_pos, enemy_pos: [row, col] in 5x5 grid (1-based)
% turn: current turn number
% game_over: true if won/lost
% winner: 'player', 'enemy', or 'quit'

function game_state = init_game()
    game_state.player_army = 100;
    game_state.enemy_army = 100;
    game_state.player_morale = 100;
    game_state.enemy_morale = 100;
    game_state.player_resources = 50;
    game_state.enemy_resources = 50;
    game_state.player_pos = [1, 1]; % Start at top-left
    game_state.enemy_pos = [5, 5];  % Start at bottom-right
    game_state.turn = 0;
    game_state.game_over = false;
    game_state.winner = '';
endfunction

function display_map(state)
    printf('\n=== BATTLEFIELD MAP ===\n');
    for row = 1:5
        for col = 1:5
            if isequal([row, col], state.player_pos) && isequal([row, col], state.enemy_pos)
                printf(' B '); % Both player and enemy
            elseif isequal([row, col], state.player_pos)
                printf(' P '); % Player
            elseif isequal([row, col], state.enemy_pos)
                printf(' E '); % Enemy
            else
                printf(' . '); % Empty
            endif
        endfor
        printf('\n');
    endfor
    printf('P = Player, E = Enemy, B = Both\n');
    printf('======================\n');
endfunction

function display_status(state)
    printf('\n=====================================\n');
    printf('         TEXT WAR GAME STATUS        \n');
    printf('=====================================\n');
    printf('Turn: %d\n', state.turn);
    printf('Player Army: %d/100 (%.0f%%)\n', state.player_army, (state.player_army / 100) * 100);
    printf('Player Morale: %.0f%%\n', state.player_morale);
    printf('Player Resources: %d\n', state.player_resources);
    printf('Player Position: (%d, %d)\n', state.player_pos(1), state.player_pos(2));
    printf('\n');
    printf('Enemy Army: %d/100 (%.0f%%)\n', state.enemy_army, (state.enemy_army / 100) * 100);
    printf('Enemy Morale: %.0f%%\n', state.enemy_morale);
    printf('Enemy Resources: %d\n', state.enemy_resources);
    printf('Enemy Position: (%d, %d)\n', state.enemy_pos(1), state.enemy_pos(2));
    printf('=====================================\n');
    printf('Battlefield: Open Plains | Weather: Clear\n');
    printf('=====================================\n');
endfunction

function can_attack = check_proximity(state)
    % Attack allowed if player and enemy are in same or adjacent cells
    dist = abs(state.player_pos(1) - state.enemy_pos(1)) + abs(state.player_pos(2) - state.enemy_pos(2));
    can_attack = dist <= 1; % Manhattan distance <= 1 (same or adjacent cell)
endfunction

function display_menu(state)
    printf('\nChoose your command:\n');
    printf('1. Move North\n');
    printf('2. Move South\n');
    printf('3. Move East\n');
    printf('4. Move West\n');
    if check_proximity(state)
        printf('5. Attack (Deal damage to enemy)\n');
    else
        printf('5. Attack (Disabled: Enemy too far)\n');
    endif
    printf('6. Defend (Boost morale, reduce incoming damage)\n');
    printf('7. Scout (Gather intel, slight resource gain)\n');
    printf('8. Retreat (Reduce losses but lower morale)\n');
    printf('9. Status (View current status again)\n');
    printf('10. Quit (End game)\n');
    printf('Enter choice (1-10): ');
endfunction

function state = process_player_command(state, choice)
    switch choice
        case 1  % Move North
            if state.player_pos(1) > 1
                state.player_pos(1) = state.player_pos(1) - 1;
                state.player_resources = max(0, state.player_resources - 2);
                printf('You move North.\n');
            else
                printf('Cannot move North: at map edge.\n');
            endif
            
        case 2  % Move South
            if state.player_pos(1) < 5
                state.player_pos(1) = state.player_pos(1) + 1;
                state.player_resources = max(0, state.player_resources - 2);
                printf('You move South.\n');
            else
                printf('Cannot move South: at map edge.\n');
            endif
            
        case 3  % Move East
            if state.player_pos(2) < 5
                state.player_pos(2) = state.player_pos(2) + 1;
                state.player_resources = max(0, state.player_resources - 2);
                printf('You move East.\n');
            else
                printf('Cannot move East: at map edge.\n');
            endif
            
        case 4  % Move West
            if state.player_pos(2) > 1
                state.player_pos(2) = state.player_pos(2) - 1;
                state.player_resources = max(0, state.player_resources - 2);
                printf('You move West.\n');
            else
                printf('Cannot move West: at map edge.\n');
            endif
            
        case 5  % Attack
            if check_proximity(state)
                damage = randi([10, 25]);
                state.enemy_army = max(0, state.enemy_army - damage);
                state.player_morale = min(100, state.player_morale + 5);
                printf('You launch an attack! Enemy loses %d troops.\n', damage);
            else
                printf('Cannot attack: Enemy is too far away!\n');
            endif
            
        case 6  % Defend
            state.player_morale = min(100, state.player_morale + 10);
            state.player_resources = min(100, state.player_resources + 5);
            printf('You fortify defenses. Morale boosted!\n');
            
        case 7  % Scout
            intel = randi([1, 3]);
            state.player_resources = min(100, state.player_resources + intel * 5);
            printf('Scouting reveals enemy weaknesses. Gained %d resources.\n', intel * 5);
            
        case 8  % Retreat
            state.player_army = max(0, state.player_army - randi([5, 10]));
            state.player_morale = max(0, state.player_morale - 15);
            printf('Strategic retreat. Minor losses, but morale suffers.\n');
            
        case 9  % Status
            display_status(state);
            display_map(state);
            % No state change
            
        case 10 % Quit
            state.game_over = true;
            state.winner = 'quit';
            printf('Game ended by player.\n');
            return;
            
        otherwise
            printf('Invalid choice. No action taken.\n');
    endswitch
endfunction

function state = enemy_ai_turn(state)
    % Enemy AI: Move towards player or perform action
    if rand() < 0.7  % 70% chance to move towards player
        row_diff = state.player_pos(1) - state.enemy_pos(1);
        col_diff = state.player_pos(2) - state.enemy_pos(2);
        if abs(row_diff) > abs(col_diff)
            % Move vertically
            if row_diff > 0 && state.enemy_pos(1) < 5
                state.enemy_pos(1) = state.enemy_pos(1) + 1;
                printf('Enemy moves South.\n');
            elseif row_diff < 0 && state.enemy_pos(1) > 1
                state.enemy_pos(1) = state.enemy_pos(1) - 1;
                printf('Enemy moves North.\n');
            endif
        else
            % Move horizontally
            if col_diff > 0 && state.enemy_pos(2) < 5
                state.enemy_pos(2) = state.enemy_pos(2) + 1;
                printf('Enemy moves East.\n');
            elseif col_diff < 0 && state.enemy_pos(2) > 1
                state.enemy_pos(2) = state.enemy_pos(2) - 1;
                printf('Enemy moves West.\n');
            endif
        endif
        state.enemy_resources = max(0, state.enemy_resources - 2);
    else
        % Random action: attack (if close), defend, or scout
        if check_proximity(state)
            damage = randi([8, 20]);
            state.player_army = max(0, state.player_army - damage);
            state.enemy_morale = min(100, state.enemy_morale + 3);
            printf('Enemy attacks! You lose %d troops.\n', damage);
        elseif rand() < 0.7
            state.enemy_morale = min(100, state.enemy_morale + 8);
            state.enemy_resources = min(100, state.enemy_resources + 3);
            printf('Enemy strengthens defenses.\n');
        else
            state.enemy_resources = min(100, state.enemy_resources + randi([2, 5]));
            printf('Enemy scouts the field.\n');
        endif
    endif
endfunction

function state = resolve_battle(state)
    % Morale decay based on army losses
    state.player_morale = max(0, state.player_morale - (100 - state.player_army) / 20);
    state.enemy_morale = max(0, state.enemy_morale - (100 - state.enemy_army) / 20);
    
    % Resource consumption
    state.player_resources = max(0, state.player_resources - randi([2, 5]));
    state.enemy_resources = max(0, state.enemy_resources - randi([1, 4]));
endfunction

function [game_over, winner] = check_end(state)
    if state.player_army <= 0 || state.player_morale <= 0
        game_over = true;
        winner = 'enemy';
    elseif state.enemy_army <= 0 || state.enemy_morale <= 0
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
    printf('Navigate the battlefield (5x5 grid) to engage the enemy.\n');
    printf('Move close (same or adjacent cell) to attack.\n\n');
    
    while ~state.game_over
        state.turn = state.turn + 1;
        display_status(state);
        display_map(state);
        display_menu(state);
        
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
        pause(); % Wait for user input
    endwhile
    
    display_status(state);
    display_map(state);
    show_end_screen(state.winner);
endfunction

% Run the game
main();
