# TeltonikaSMS [Zpět](../README.md)

Komunikace s routrem od Teltonika přes http pro management SMS zpráv.

## Použití

Volání bloku se správně nastavenými paramtry. *execute* reaguje na náběznou hranu. *Status* je aktivní (*Error* či *OK*) tak dlouho, dokud je aktivní *execute*.

### Systémové parametry

- `enable`: Povolení bloku.
- `execute`: Proveden9 u6ivatelského příkazu.
- `pRouterAddress`: IP adreasa routeru. `ADR(STRING)`
- `pUsername`: Nastavené jméno v routeru - v nastavení API. `ADR(STRING)`
- `pPassword`: Nastavené heslo v routeru - v nastavení API. `ADR(STRING)`

### Uživatelské parametry

- `requestType`: Typ požadavku
    - `teltonikaReqType_EnMobileData`: Povolení používání mobilních dat. Uživatelské paramerty: *uEnableData*.
    - `teltonikaReqType_SetSimPin`: Uživatelské paramerty: *upSimPin*.
    - `teltonikaReqType_ViewMsgList`: Seznam přijatých zpráv.
    - `teltonikaReqType_ReadMsg`: Uživatelské paramerty: *uMsgId*.
    - `teltonikaReqType_SendMsg`: Uživatelské paramerty: *upNumber, upMsgText*.
    - `teltonikaReqType_SendMsgGroup`: Uživatelské paramerty: *upGroup, upMsgText*.
    - `teltonikaReqType_ViewMsgTotal`: Přehled přijatých zpráv.
    - `teltonikaReqType_DeleteMsg`: Smazání zprávy. Uživatelské paramerty: *uMsgId*.
- `uEnableData`: Povolení mobilních dat. `ADR(STRING)`
- `upSimPin`: Pin k simkartě. `ADR(STRING)`
- `uMsgId`: ID zprávy. `UDINT`
- `upNumber`: Telefonní číslo příjemce. Formát je 00420604387347 (*00*+*předvolba*+*číslo*). `ADR(STRING)`
- `upGroup`: Jméno skupiny telefonních čísel. `ADR(STRING)`
- `upMsgText`: Text zprávy. `ADR(STRING)`

### Výstupy

- `status`: 
    - `teltonikaSmsStatus_NotEnabled`: Není povolen. Nic se neprovádí
    - `teltonikaSmsStatus_Wait`: Čeká na příkaz (*execute*).
    - `teltonikaSmsStatus_Busy`: Provádí příkaz.
    - `teltonikaSmsStatus_Error`: Chyba.
    - `teltonikaSmsStatus_Ok`: Provedeno v pořádku.
- `uMsgCount`: Počet zpráv celkem. (nepoužito)

## Changelog

### V0.1.0

První funkční verze. Použitelné jsou všechny typy komunikace, jenom odpovědi nejsou dále zpracovány.
