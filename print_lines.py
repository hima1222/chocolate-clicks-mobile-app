import pathlib
lines=pathlib.Path(r'D:\Moblie Application\chocolate_clicks\lib\screens\edit_profile_screen.dart').read_text(encoding='utf-8').splitlines()
for i,l in enumerate(lines,1):
    if 240<=i<=265:
        print(f"{i}: {l}")
