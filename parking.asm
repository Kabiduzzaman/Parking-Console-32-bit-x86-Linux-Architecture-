; ==============================================================================
;  EVO Parking TERMINAL 
; Architecture: 32-Bit x86 Linux NASM
; Assemble:     nasm -f elf32 parking.asm -o parking.o
; Link:         ld -m elf_i386 parking.o -o parking
; Run:          ./parking
; ==============================================================================

section .data
    ; --- MAIN CUSTOMER MENU ---
    menu_msg    db 10, "======================================================", 10
                db "         HELLO, THERE! WELCOME TO EVO PARKING.        ", 10
                db "======================================================", 10
                db "1. View Bay Status", 10
                db "2. Park a Vehicle (Bays 1-5)", 10
                db "3. Park & Charge an EV (EV Bays 6-7)", 10
                db "4. Checkout (Bays 1-7)", 10
                db "5. View Pricing & Tariff Schedule", 10
                db "6. Submit Customer Feedback or Complaint", 10
                db "7. View Customer Support & Helpdesk Info", 10
                db "8. System Settings", 10
                db "9. Exit Terminal", 10
                db "Select an option (1-9): "
    menu_len    equ $ - menu_msg

    ; --- SETTINGS & ADMIN SUB-MENU ---
    set_menu    db 10, "------------------------------------------------------", 10
                db "         SYSTEM SETTINGS & ADMIN CONTROL PANEL        ", 10
                db "------------------------------------------------------", 10
                db "1. Advance IoT Sensor Clock (Simulate +Hours)", 10
                db "2. View Total Daily Revenue", 10
                db "3. Manually Unlock Barricade (Bays 1-7 / Main Gate)", 10
                db "4. View Customer Feedback & Complaints", 10
                db "5. Log Out & Return to Main Menu", 10
                db "Select a setting (1-5): "
    set_len     equ $ - set_menu

    ; --- PRICING & TARIFF SCHEDULE (Option 5) ---
    price_table db 10, "======================================================", 10
                db "             OFFICIAL PRICING & TARIFF RATES          ", 10
                db "======================================================", 10
                db "[STANDARD PARKING BAYS: 1 TO 5]", 10
                db "  * Normal Rate (1 - 24 Hours)    : RM 5 / hour", 10
                db "  * Extended Rate (25 - 48 Hours) : RM 10 / hour", 10
                db "  * Overstay (> 48 Hours)         : Wheel Clamped!", 10
                db "    (Max 48h Fee RM 480 + RM 100 Clamping Fine)", 10, 10
                db "[EV CHARGING BAYS: 6 TO 7]", 10
                db "  * Normal Rate (1 - 24 Hours)    : RM 8 / hour", 10
                db "  * Extended Rate (25 - 48 Hours) : RM 12 / hour", 10
                db "  * Overstay (> 48 Hours)         : Wheel Clamped!", 10
                db "    (Max 48h Fee RM 576 + RM 150 EV Clamping Fine)", 10
                db "======================================================", 10
    ptable_len  equ $ - price_table

    ; --- BAY TELEMETRY MESSAGES ---
    std_hdr     db 10, "--- STANDARD PARKING BAYS (1 - 5) ---", 10
    std_hlen    equ $ - std_hdr

    ev_hdr      db 10, 10, "--- EV CHARGING BAYS (6 - 7) ---", 10
    ev_hlen     equ $ - ev_hdr

    bay_label   db "Bay "
    ev_label    db "EV Bay "
    bay_free    db ": [ FREE ]   "
    bay_occ1    db ": [OCCUPIED: "
    bay_occ2    db "h]   "
    newline     db 10

    ; --- CHECK-IN & FULL LOT APOLOGY MESSAGES ---
    prompt_std  db 10, "Enter Standard Bay number (1-5): "
    pstd_len    equ $ - prompt_std

    prompt_ev   db 10, "Enter EV Charging Bay number (6-7): "
    pev_len     equ $ - prompt_ev

    prompt_out  db 10, "Enter Bay number for checkout (1-7): "
    pout_len    equ $ - prompt_out

    msg_parked  db ">> Success: Vehicle parked! Ultrasonic timer started at 1h.", 10
    mparked_len equ $ - msg_parked

    msg_ev_park db ">> Success: EV connected to charger! Timer started at 1h.", 10
    mev_len     equ $ - msg_ev_park

    full_std    db 10, ">> Notice: All Standard Parking Bays (1-5) are currently occupied.", 10
                db ">> We are sorry for the inconvenience!", 10
    fstd_len    equ $ - full_std

    full_ev     db 10, ">> Notice: All EV Charging Bays (6-7) are currently occupied.", 10
                db ">> We are sorry for the inconvenience!", 10
    fev_len     equ $ - full_ev

    ; --- SENSOR SIMULATION MESSAGES ---
    sim_prompt  db 10, "Enter hours to advance active bay sensors (1-60): "
    sim_plen    equ $ - sim_prompt

    sim_done    db ">> Success: All occupied Standard & EV bay timers updated.", 10
    sim_dlen    equ $ - sim_done

    ; --- ERROR MESSAGES ---
    err_taken   db ">> Error: Selected bay is already occupied.", 10
    etaken_len  equ $ - err_taken

    err_empty   db ">> Error: Selected bay is currently empty.", 10
    eempty_len  equ $ - err_empty

    err_invalid db ">> Error: Invalid selection. Please try again.", 10
    einv_len    equ $ - err_invalid

    ; --- PAYMENT MENU MESSAGES ---
    fee_preview db 10, ">> Amount Due: RM "
    fprev_len   equ $ - fee_preview

    pay_menu    db 10, "--- SELECT PAYMENT METHOD ---", 10
                db "1. Cash (RM Notes)", 10
                db "2. Credit / Debit Card (PayWave)", 10
                db "3. Touch 'n Go eWallet / DuitNow QR", 10
                db "Select payment method (1-3): "
    pay_len     equ $ - pay_menu

    ; --- ITEMIZED RECEIPT STRINGS ---
    rcpt_top    db 10, "======================================================", 10
                db "               OFFICIAL PARKING RECEIPT               ", 10
                db "======================================================", 10
    rtop_len    equ $ - rcpt_top

    rcpt_bay    db "Bay Number         : Bay "
    rbay_len    equ $ - rcpt_bay

    rcpt_t_std  db "Bay Category       : Standard Parking", 10
    rtstd_len   equ $ - rcpt_t_std

    rcpt_t_ev   db "Bay Category       : EV Charging Station", 10
    rtev_len    equ $ - rcpt_t_ev

    rcpt_dur    db "Logged Duration    : "
    rdur_len    equ $ - rcpt_dur

    rcpt_hrs    db " hour(s)"
    rhrs_len    equ $ - rcpt_hrs

    rcpt_clamp  db " [OVERSTAY >48h: CAPPED AT 48h]", 10
    rclamp_len  equ $ - rcpt_clamp

    rcpt_rate   db "Applied Hourly Rate: RM "
    rrate_len   equ $ - rcpt_rate

    rcpt_per_hr db " / hour", 10
    rphr_len    equ $ - rcpt_per_hr

    rcpt_base   db "Parking/Charge Fee : RM "
    rbase_len   equ $ - rcpt_base

    rcpt_fine   db "Wheel Clamp Fine   : RM "
    rfine_len   equ $ - rcpt_fine

    rcpt_line   db "------------------------------------------------------", 10
    rline_len   equ $ - rcpt_line

    rcpt_tot    db "TOTAL AMOUNT PAID  : RM "
    rtot_len    equ $ - rcpt_tot

    rcpt_p_cash db "Payment Method     : Cash (RM Notes)", 10
    rpcash_len  equ $ - rcpt_p_cash

    rcpt_p_card db "Payment Method     : Credit / Debit Card", 10
    rpcard_len  equ $ - rcpt_p_card

    rcpt_p_qr   db "Payment Method     : Touch 'n Go / DuitNow QR", 10
    rpqr_len    equ $ - rcpt_p_qr

    rcpt_bot    db "Status             : PAID - Barricade Opened", 10
                db "       Thank you and drive safely! See you again.     ", 10
                db "======================================================", 10
    rbot_len    equ $ - rcpt_bot

    ; --- ADMIN SECURITY & OVERRIDE MESSAGES ---
    admin_hdr   db 10, "--- ADMIN SECURITY LOGIN REQUIRED ---", 10
    ahdr_len    equ $ - admin_hdr

    user_prompt db "Admin Username: "
    uprompt_len equ $ - user_prompt

    pass_prompt db "Admin Password: "
    pprompt_len equ $ - pass_prompt

    admin_user  db "admin", 10
    admin_pass  db "1234", 10

    auth_ok_msg db ">> [ACCESS GRANTED] Admin session unlocked.", 10
    aok_msg_len equ $ - auth_ok_msg

    auth_err    db ">> [ACCESS DENIED] Invalid admin credentials. Returning to Main Menu.", 10
    aerr_len    equ $ - auth_err

    logout_msg  db ">> Admin session closed. Returning to Main Menu...", 10
    logout_len  equ $ - logout_msg

    rev_out_msg db 10, ">> Total Daily Revenue Collected: RM "
    rev_out_len equ $ - rev_out_msg

    bar_prompt  db 10, "--- MANUAL BARRICADE OVERRIDE ---", 10
                db "Enter bay number to release & clear (1-7), or 0 for Main Gate only: "
    bar_plen    equ $ - bar_prompt

    bar_msg1    db ">> [OVERRIDE ACTIVE] Barricade unlocked and bay sensor reset to FREE.", 10
    bar_mlen1   equ $ - bar_msg1

    bar_msg0    db ">> [OVERRIDE ACTIVE] Main exit barricade manually unlocked!", 10
    bar_mlen0   equ $ - bar_msg0

    ; --- FEEDBACK & SUPPORT MESSAGES ---
    fb_prompt   db 10, "--- CUSTOMER FEEDBACK & COMPLAINT ---", 10
                db "Enter your message below and press ENTER:", 10, "> "
    fb_plen     equ $ - fb_prompt

    fb_thanks   db ">> Thank you! Your feedback has been recorded for management.", 10
    fb_tlen     equ $ - fb_thanks

    fb_view_hdr db 10, "--- CUSTOMER FEEDBACK & COMPLAINTS LOG ---", 10
                db "Total Submissions Today: "
    fb_vhlen    equ $ - fb_view_hdr

    fb_latest   db "Latest Recorded Message: ", 10, "  > "
    fb_latlen   equ $ - fb_latest

    fb_empty    db 10, ">> No customer feedback or complaints recorded yet.", 10
    fb_emplen   equ $ - fb_empty

    sup_msg     db 10, "--- 24/7 CUSTOMER SUPPORT & HELPDESK ---", 10
                db "Hotline  : 1-800-88-PARK (7275)", 10
                db "WhatsApp : +60 12-345 6789 (Clamping & EV Charger Help)", 10
                db "Email    : support@smartparking.com.my", 10
                db "Location : Level 2, Carpark Management Office", 10
    sup_len     equ $ - sup_msg

    ; --- SYSTEM STATE ARRAYS & VARIABLES (7 BAYS TOTAL) ---
    slots       db 0, 0, 0, 0, 0, 0, 0
    slot_hours  dd 0, 0, 0, 0, 0, 0, 0
    revenue     dd 0

    ; Feedback Tracking Variables
    fb_count    dd 0                    ; Number of feedback messages submitted
    fb_len      dd 0                    ; Byte length of the latest feedback message

    ; Temporary Checkout Receipt Variables
    co_bay      dd 0
    co_is_ev    dd 0
    co_raw_hrs  dd 0
    co_rate     dd 0
    co_base_fee dd 0
    co_fine     dd 0
    co_total    dd 0
    co_pay_type dd 0

section .bss
    in_buf      resb 64
    fb_buf      resb 128                ; Stores customer feedback text
    num_buf     resb 16
    char_buf    resb 4

section .text
    global _start

_start:
main_loop:
    mov ecx, menu_msg
    mov edx, menu_len
    call print_str

    call read_int                       ; Read user choice (1-9)

    cmp eax, 1
    je view_lot
    cmp eax, 2
    je park_standard
    cmp eax, 3
    je park_ev
    cmp eax, 4
    je checkout_car
    cmp eax, 5
    je show_pricing
    cmp eax, 6
    je customer_feedback
    cmp eax, 7
    je customer_support
    cmp eax, 8
    je settings_entry
    cmp eax, 9
    je exit_program

    mov ecx, err_invalid
    mov edx, einv_len
    call print_str
    jmp main_loop

; ------------------------------------------------------------------------------
; FEATURE 1: VIEW LIVE PARKING & EV BAY STATUS
; ------------------------------------------------------------------------------
view_lot:
    mov ecx, std_hdr
    mov edx, std_hlen
    call print_str

    xor esi, esi
std_view_loop:
    cmp esi, 5
    jge ev_view_section

    mov ecx, bay_label
    mov edx, 4
    call print_str

    mov eax, esi
    inc eax
    add al, '0'
    mov [char_buf], al
    mov ecx, char_buf
    mov edx, 1
    call print_str

    movzx eax, byte [slots + esi]
    cmp eax, 1
    je std_occupied

    mov ecx, bay_free
    mov edx, 13
    call print_str
    jmp std_next

std_occupied:
    mov ecx, bay_occ1
    mov edx, 13
    call print_str

    mov eax, [slot_hours + esi*4]
    call print_int_no_nl

    mov ecx, bay_occ2
    mov edx, 5
    call print_str

std_next:
    inc esi
    jmp std_view_loop

ev_view_section:
    mov ecx, ev_hdr
    mov edx, ev_hlen
    call print_str

    mov esi, 5
ev_view_loop:
    cmp esi, 7
    jge view_done

    mov ecx, ev_label
    mov edx, 7
    call print_str

    mov eax, esi
    inc eax
    add al, '0'
    mov [char_buf], al
    mov ecx, char_buf
    mov edx, 1
    call print_str

    movzx eax, byte [slots + esi]
    cmp eax, 1
    je ev_occupied

    mov ecx, bay_free
    mov edx, 13
    call print_str
    jmp ev_next

ev_occupied:
    mov ecx, bay_occ1
    mov edx, 13
    call print_str

    mov eax, [slot_hours + esi*4]
    call print_int_no_nl

    mov ecx, bay_occ2
    mov edx, 5
    call print_str

ev_next:
    inc esi
    jmp ev_view_loop

view_done:
    mov ecx, newline
    mov edx, 1
    call print_str
    jmp main_loop

; ------------------------------------------------------------------------------
; FEATURE 2: PARK A STANDARD VEHICLE (Bays 1-5)
; ------------------------------------------------------------------------------
park_standard:
    xor esi, esi
check_std_full_loop:
    cmp esi, 5
    jge all_std_full
    cmp byte [slots + esi], 0
    je prompt_std_bay
    inc esi
    jmp check_std_full_loop

all_std_full:
    mov ecx, full_std
    mov edx, fstd_len
    call print_str
    jmp main_loop

prompt_std_bay:
    mov ecx, prompt_std
    mov edx, pstd_len
    call print_str

    call read_int
    cmp eax, 1
    jl invalid_input
    cmp eax, 5
    jg invalid_input

    dec eax
    mov ebx, eax

    cmp byte [slots + ebx], 1
    je slot_is_taken

    mov byte [slots + ebx], 1
    mov dword [slot_hours + ebx*4], 1

    mov ecx, msg_parked
    mov edx, mparked_len
    call print_str
    jmp main_loop

; ------------------------------------------------------------------------------
; FEATURE 3: PARK & CHARGE AN EV (EV Bays 6-7)
; ------------------------------------------------------------------------------
park_ev:
    mov esi, 5
check_ev_full_loop:
    cmp esi, 7
    jge all_ev_full
    cmp byte [slots + esi], 0
    je prompt_ev_bay
    inc esi
    jmp check_ev_full_loop

all_ev_full:
    mov ecx, full_ev
    mov edx, fev_len
    call print_str
    jmp main_loop

prompt_ev_bay:
    mov ecx, prompt_ev
    mov edx, pev_len
    call print_str

    call read_int
    cmp eax, 6
    jl invalid_input
    cmp eax, 7
    jg invalid_input

    dec eax
    mov ebx, eax

    cmp byte [slots + ebx], 1
    je slot_is_taken

    mov byte [slots + ebx], 1
    mov dword [slot_hours + ebx*4], 1

    mov ecx, msg_ev_park
    mov edx, mev_len
    call print_str
    jmp main_loop

slot_is_taken:
    mov ecx, err_taken
    mov edx, etaken_len
    call print_str
    jmp main_loop

invalid_input:
    mov ecx, err_invalid
    mov edx, einv_len
    call print_str
    jmp main_loop

; ------------------------------------------------------------------------------
; FEATURE 4: CHECKOUT, DYNAMIC FEE CALCULATION & ITEMIZED RECEIPT
; ------------------------------------------------------------------------------
checkout_car:
    mov ecx, prompt_out
    mov edx, pout_len
    call print_str

    call read_int
    cmp eax, 1
    jl invalid_input
    cmp eax, 7
    jg invalid_input

    mov [co_bay], eax
    dec eax
    mov ebx, eax

    cmp byte [slots + ebx], 0
    je slot_is_empty

    mov esi, [slot_hours + ebx*4]
    mov [co_raw_hrs], esi

    mov byte [slots + ebx], 0
    mov dword [slot_hours + ebx*4], 0

    cmp ebx, 5
    jge calc_ev_pricing

; --- STANDARD BAY PRICING ---
calc_std_pricing:
    mov dword [co_is_ev], 0
    cmp esi, 24
    jle std_tier1
    cmp esi, 48
    jle std_tier2

    mov dword [co_rate], 10
    mov eax, 48
    mov ecx, 10
    mul ecx
    mov [co_base_fee], eax
    mov dword [co_fine], 100
    add eax, 100
    mov [co_total], eax
    jmp prompt_payment

std_tier1:
    mov dword [co_rate], 5
    mov eax, esi
    mov ecx, 5
    mul ecx
    mov [co_base_fee], eax
    mov dword [co_fine], 0
    mov [co_total], eax
    jmp prompt_payment

std_tier2:
    mov dword [co_rate], 10
    mov eax, esi
    mov ecx, 10
    mul ecx
    mov [co_base_fee], eax
    mov dword [co_fine], 0
    mov [co_total], eax
    jmp prompt_payment

; --- EV BAY PRICING ---
calc_ev_pricing:
    mov dword [co_is_ev], 1
    cmp esi, 24
    jle ev_tier1
    cmp esi, 48
    jle ev_tier2

    mov dword [co_rate], 12
    mov eax, 48
    mov ecx, 12
    mul ecx
    mov [co_base_fee], eax
    mov dword [co_fine], 150
    add eax, 150
    mov [co_total], eax
    jmp prompt_payment

ev_tier1:
    mov dword [co_rate], 8
    mov eax, esi
    mov ecx, 8
    mul ecx
    mov [co_base_fee], eax
    mov dword [co_fine], 0
    mov [co_total], eax
    jmp prompt_payment

ev_tier2:
    mov dword [co_rate], 12
    mov eax, esi
    mov ecx, 12
    mul ecx
    mov [co_base_fee], eax
    mov dword [co_fine], 0
    mov [co_total], eax

prompt_payment:
    mov eax, [co_total]
    add [revenue], eax

    mov ecx, fee_preview
    mov edx, fprev_len
    call print_str
    mov eax, [co_total]
    call print_int

payment_loop:
    mov ecx, pay_menu
    mov edx, pay_len
    call print_str

    call read_int
    cmp eax, 1
    jl invalid_pay
    cmp eax, 3
    jg invalid_pay

    mov [co_pay_type], eax
    jmp generate_receipt

invalid_pay:
    mov ecx, err_invalid
    mov edx, einv_len
    call print_str
    jmp payment_loop

generate_receipt:
    mov ecx, rcpt_top
    mov edx, rtop_len
    call print_str

    mov ecx, rcpt_bay
    mov edx, rbay_len
    call print_str
    mov eax, [co_bay]
    call print_int

    cmp dword [co_is_ev], 1
    je rcpt_print_ev_cat
    mov ecx, rcpt_t_std
    mov edx, rtstd_len
    call print_str
    jmp rcpt_print_dur

rcpt_print_ev_cat:
    mov ecx, rcpt_t_ev
    mov edx, rtev_len
    call print_str

rcpt_print_dur:
    mov ecx, rcpt_dur
    mov edx, rdur_len
    call print_str
    mov eax, [co_raw_hrs]
    call print_int_no_nl
    mov ecx, rcpt_hrs
    mov edx, rhrs_len
    call print_str

    cmp dword [co_raw_hrs], 48
    jg rcpt_print_cap_note
    mov ecx, newline
    mov edx, 1
    call print_str
    jmp rcpt_print_rate

rcpt_print_cap_note:
    mov ecx, rcpt_clamp
    mov edx, rclamp_len
    call print_str

rcpt_print_rate:
    mov ecx, rcpt_rate
    mov edx, rrate_len
    call print_str
    mov eax, [co_rate]
    call print_int_no_nl
    mov ecx, rcpt_per_hr
    mov edx, rphr_len
    call print_str

    mov ecx, rcpt_base
    mov edx, rbase_len
    call print_str
    mov eax, [co_base_fee]
    call print_int

    mov ecx, rcpt_fine
    mov edx, rfine_len
    call print_str
    mov eax, [co_fine]
    call print_int

    mov ecx, rcpt_line
    mov edx, rline_len
    call print_str

    mov ecx, rcpt_tot
    mov edx, rtot_len
    call print_str
    mov eax, [co_total]
    call print_int

    mov eax, [co_pay_type]
    cmp eax, 1
    je rcpt_pay1
    cmp eax, 2
    je rcpt_pay2

    mov ecx, rcpt_p_qr
    mov edx, rpqr_len
    call print_str
    jmp rcpt_finish

rcpt_pay1:
    mov ecx, rcpt_p_cash
    mov edx, rpcash_len
    call print_str
    jmp rcpt_finish

rcpt_pay2:
    mov ecx, rcpt_p_card
    mov edx, rpcard_len
    call print_str

rcpt_finish:
    mov ecx, rcpt_bot
    mov edx, rbot_len
    call print_str
    jmp main_loop

slot_is_empty:
    mov ecx, err_empty
    mov edx, eempty_len
    call print_str
    jmp main_loop

; ------------------------------------------------------------------------------
; FEATURE 5: VIEW PRICING & TARIFF SCHEDULE
; ------------------------------------------------------------------------------
show_pricing:
    mov ecx, price_table
    mov edx, ptable_len
    call print_str
    jmp main_loop

; ------------------------------------------------------------------------------
; FEATURE 6 & 7: CUSTOMER FEEDBACK & CUSTOMER SUPPORT
; ------------------------------------------------------------------------------
customer_feedback:
    mov ecx, fb_prompt
    mov edx, fb_plen
    call print_str

    mov eax, 3                          ; sys_read returns number of bytes read in EAX
    mov ebx, 0
    mov ecx, fb_buf
    mov edx, 128
    int 0x80

    mov [fb_len], eax                   ; Save byte length of the customer's message
    inc dword [fb_count]                ; Increment total feedback counter (Arithmetic)

    mov ecx, fb_thanks
    mov edx, fb_tlen
    call print_str
    jmp main_loop

customer_support:
    mov ecx, sup_msg
    mov edx, sup_len
    call print_str
    jmp main_loop

; ------------------------------------------------------------------------------
; FEATURE 8: SYSTEM SETTINGS & ADMIN CONTROLS (Single Login Gate)
; ------------------------------------------------------------------------------
settings_entry:
    call admin_login
    cmp eax, 1
    jne main_loop

settings_loop:
    mov ecx, set_menu
    mov edx, set_len
    call print_str

    call read_int

    cmp eax, 1
    je simulate_sensor_clock
    cmp eax, 2
    je admin_revenue
    cmp eax, 3
    je admin_unlock_barricade
    cmp eax, 4
    je admin_view_feedback
    cmp eax, 5
    je admin_logout

    mov ecx, err_invalid
    mov edx, einv_len
    call print_str
    jmp settings_loop

; --- SETTING 1: ADVANCE IoT SENSOR CLOCK ---
simulate_sensor_clock:
    mov ecx, sim_prompt
    mov edx, sim_plen
    call print_str

    call read_int
    cmp eax, 1
    jl set_invalid_input

    mov ebx, eax
    xor esi, esi

sim_loop:
    cmp esi, 7
    jge sim_finished

    cmp byte [slots + esi], 1
    jne sim_next

    add [slot_hours + esi*4], ebx

sim_next:
    inc esi
    jmp sim_loop

sim_finished:
    mov ecx, sim_done
    mov edx, sim_dlen
    call print_str
    jmp settings_loop

; --- SETTING 2: VIEW TOTAL DAILY REVENUE ---
admin_revenue:
    mov ecx, rev_out_msg
    mov edx, rev_out_len
    call print_str

    mov eax, [revenue]
    call print_int
    jmp settings_loop

; --- SETTING 3: MANUALLY UNLOCK BARRICADE ---
admin_unlock_barricade:
    mov ecx, bar_prompt
    mov edx, bar_plen
    call print_str

    call read_int
    cmp eax, 0
    je unlock_main_gate
    cmp eax, 1
    jl set_invalid_input
    cmp eax, 7
    jg set_invalid_input

    dec eax
    mov ebx, eax
    mov byte [slots + ebx], 0
    mov dword [slot_hours + ebx*4], 0

    mov ecx, bar_msg1
    mov edx, bar_mlen1
    call print_str
    jmp settings_loop

unlock_main_gate:
    mov ecx, bar_msg0
    mov edx, bar_mlen0
    call print_str
    jmp settings_loop

; --- SETTING 4: VIEW CUSTOMER FEEDBACK & COMPLAINTS ---
admin_view_feedback:
    cmp dword [fb_count], 0             ; Check if any feedback exists
    je no_feedback_yet

    mov ecx, fb_view_hdr
    mov edx, fb_vhlen
    call print_str

    mov eax, [fb_count]
    call print_int                      ; Print total number of feedback submissions

    mov ecx, fb_latest
    mov edx, fb_latlen
    call print_str

    ; Print the actual customer message stored in fb_buf
    mov ecx, fb_buf
    mov edx, [fb_len]
    call print_str
    jmp settings_loop

no_feedback_yet:
    mov ecx, fb_empty
    mov edx, fb_emplen
    call print_str
    jmp settings_loop

; --- SETTING 5: LOG OUT ---
admin_logout:
    mov ecx, logout_msg
    mov edx, logout_len
    call print_str
    jmp main_loop

set_invalid_input:
    mov ecx, err_invalid
    mov edx, einv_len
    call print_str
    jmp settings_loop

; ------------------------------------------------------------------------------
; FEATURE 9: EXIT SYSTEM
; ------------------------------------------------------------------------------
exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; ==============================================================================
; HELPER SUBROUTINES
; ==============================================================================
admin_login:
    mov ecx, admin_hdr
    mov edx, ahdr_len
    call print_str

    mov ecx, user_prompt
    mov edx, uprompt_len
    call print_str

    mov eax, 3
    mov ebx, 0
    mov ecx, in_buf
    mov edx, 64
    int 0x80

    mov esi, in_buf
    mov edi, admin_user
    mov ecx, 6
    call verify_str
    cmp eax, 1
    jne .login_fail

    mov ecx, pass_prompt
    mov edx, pprompt_len
    call print_str

    mov eax, 3
    mov ebx, 0
    mov ecx, in_buf
    mov edx, 64
    int 0x80

    mov esi, in_buf
    mov edi, admin_pass
    mov ecx, 5
    call verify_str
    cmp eax, 1
    jne .login_fail

    mov ecx, auth_ok_msg
    mov edx, aok_msg_len
    call print_str

    mov eax, 1
    ret

.login_fail:
    mov ecx, auth_err
    mov edx, aerr_len
    call print_str
    xor eax, eax
    ret

verify_str:
.cmp_loop:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne .not_equal
    inc esi
    inc edi
    loop .cmp_loop
    mov eax, 1
    ret
.not_equal:
    xor eax, eax
    ret

print_str:
    push eax
    push ebx
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop ebx
    pop eax
    ret

read_int:
    push ebx
    push ecx
    push edx
    push esi

    mov eax, 3
    mov ebx, 0
    mov ecx, in_buf
    mov edx, 64
    int 0x80

    xor eax, eax
    xor esi, esi

.parse_loop:
    movzx ecx, byte [in_buf + esi]
    cmp cl, 10
    je .parse_done
    cmp cl, '0'
    jl .parse_done
    cmp cl, '9'
    jg .parse_done

    sub cl, '0'
    imul eax, eax, 10
    add eax, ecx
    inc esi
    jmp .parse_loop

.parse_done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

print_int:
    call print_int_no_nl
    push ecx
    push edx
    mov ecx, newline
    mov edx, 1
    call print_str
    pop edx
    pop ecx
    ret

print_int_no_nl:
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi, num_buf + 15
    mov ebx, 10

.div_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec esi
    mov [esi], dl
    test eax, eax
    jnz .div_loop

    mov ecx, esi
    mov edx, num_buf + 15
    sub edx, esi
    call print_str

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
