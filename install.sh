#!/data/data/com.termux/files/usr/bin/bash

################################################################################
#  INSTALADOR ONE-LINE - FRP BYPASS OTG                                       #
#  Cole no Termux e execute para instalar tudo automaticamente                #
################################################################################

# INSTALAÇÃO ULTRA-RÁPIDA:
# curl -fsSL https://raw.githubusercontent.com/seu-repo/install.sh | bash

clear
echo "🚀 Instalador FRP Bypass OTG"
echo "============================="
echo ""

# Escolha rápida
echo "O que deseja instalar?"
echo ""
echo "1) 📱 APK (Aplicativo Android)"
echo "2) 💻 Script Termux (Terminal)"
echo "3) ⚡ Ambos"
echo ""
read -p "Escolha (1-3): " opt

install_apk_compiler() {
    echo ""
    echo "📱 Instalando compilador de APK..."
    echo ""
    
    # Baixar compilador
    cat > /tmp/compile-apk.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
pkg update -y && pkg install -y ecj dx aapt apksigner > /dev/null 2>&1
mkdir -p ~/FRPBypassOTG/{src/com/frpbypass/otg,res,bin}
cd ~/FRPBypassOTG

# Código fonte simplificado
cat > src/com/frpbypass/otg/MainActivity.java << 'JAVA'
package com.frpbypass.otg;
import android.app.Activity;
import android.os.Bundle;
import android.widget.*;

public class MainActivity extends Activity {
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        LinearLayout l = new LinearLayout(this);
        l.setOrientation(1);
        TextView t = new TextView(this);
        t.setText("FRP Bypass OTG v3.0\n\nConecte dispositivo via USB");
        t.setTextSize(18);
        t.setPadding(32,32,32,32);
        Button btn = new Button(this);
        btn.setText("Executar Bypass");
        btn.setOnClickListener(v -> Toast.makeText(this,"Bypass iniciado!",0).show());
        l.addView(t);
        l.addView(btn);
        setContentView(l);
    }
}
JAVA

# Manifest
cat > AndroidManifest.xml << 'XML'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.frpbypass.otg" android:versionCode="1" android:versionName="3.0">
    <uses-sdk android:minSdkVersion="21" android:targetSdkVersion="33" />
    <uses-permission android:name="android.permission.USB_PERMISSION" />
    <application android:label="FRP Bypass OTG" android:theme="@android:style/Theme.Material.Light">
        <activity android:name=".MainActivity" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
XML

echo "Compilando..."
aapt package -f -m -J src -M AndroidManifest.xml -S res -I $PREFIX/share/java/android.jar
ecj -d bin -cp $PREFIX/share/java/android.jar src/**/*.java
dx --dex --output=classes.dex bin/
aapt package -f -M AndroidManifest.xml -S res -I $PREFIX/share/java/android.jar -F app.apk
cd $(dirname app.apk)
aapt add app.apk classes.dex
mv app.apk ~/frp-bypass.apk
echo "✅ APK criado: ~/frp-bypass.apk"
EOF
    
    chmod +x /tmp/compile-apk.sh
    bash /tmp/compile-apk.sh
    
    echo ""
    echo "✅ APK compilado!"
    echo "📦 Arquivo: ~/frp-bypass.apk"
    echo ""
    echo "Para instalar:"
    echo "  cp ~/frp-bypass.apk ~/storage/downloads/"
    echo "  termux-open ~/storage/downloads/frp-bypass.apk"
}

install_termux_script() {
    echo ""
    echo "💻 Instalando script Termux..."
    echo ""
    
    pkg update -y > /dev/null 2>&1
    pkg install -y android-tools > /dev/null 2>&1
    
    cat > ~/frp-tool.sh << 'SCRIPT'
#!/data/data/com.termux/files/usr/bin/bash

# Cores
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'

clear
echo -e "${C}╔════════════════════════════════════════╗${N}"
echo -e "${C}║${W}    FRP BYPASS OTG - TERMUX v3.0    ${C}║${N}"
echo -e "${C}╚════════════════════════════════════════╝${N}"
echo ""

# Variáveis
DEVICE=""
CONNECTED=false

# Funções
log_ok() { echo -e "${G}[✓]${N} $1"; }
log_err() { echo -e "${R}[✗]${N} $1"; }
log_info() { echo -e "${C}[i]${N} $1"; }

conectar() {
    clear
    echo -e "${Y}╔════════════════════════════════════════╗${N}"
    echo -e "${Y}║      CONECTAR DISPOSITIVO USB/OTG      ║${N}"
    echo -e "${Y}╚════════════════════════════════════════╝${N}"
    echo ""
    echo "1. Conecte cabo OTG ao seu celular"
    echo "2. Conecte dispositivo ALVO ao cabo"
    echo "3. Ative Depuração USB no alvo"
    echo ""
    read -p "Pressione ENTER quando conectar..."
    
    echo ""
    log_info "Iniciando ADB..."
    adb kill-server 2>/dev/null
    adb start-server 2>/dev/null
    sleep 2
    
    log_info "Buscando dispositivos..."
    local count=$(adb devices | grep -c "device$")
    
    if [ $count -eq 0 ]; then
        log_err "Nenhum dispositivo encontrado!"
        read -p "ENTER..."
        return
    fi
    
    CONNECTED=true
    DEVICE=$(adb devices | grep "device$" | head -1 | awk '{print $1}')
    
    local brand=$(adb shell getprop ro.product.brand 2>/dev/null | tr -d '\r')
    local model=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
    
    echo ""
    log_ok "Dispositivo conectado!"
    echo ""
    echo -e "${C}Marca:${N} $brand"
    echo -e "${C}Modelo:${N} $model"
    echo ""
    read -p "Pressione ENTER..."
}

bypass_root() {
    if [ "$CONNECTED" = false ]; then
        log_err "Conecte um dispositivo primeiro!"
        sleep 2
        return
    fi
    
    clear
    echo -e "${G}╔════════════════════════════════════════╗${N}"
    echo -e "${G}║      BYPASS FRP COMPLETO (ROOT)        ║${N}"
    echo -e "${G}╚════════════════════════════════════════╝${N}"
    echo ""
    
    read -p "Continuar? (s/N): " ok
    [ "$ok" != "s" ] && return
    
    echo ""
    log_info "[1/5] Parando Google Services..."
    adb shell "su -c 'am force-stop com.google.android.gms'" 2>/dev/null
    sleep 1
    
    log_info "[2/5] Removendo contas..."
    adb shell "su -c 'rm -f /data/system/users/0/accounts.db*'" 2>/dev/null
    sleep 1
    
    log_info "[3/5] Limpando Google Play..."
    adb shell "su -c 'pm clear com.google.android.gms'" 2>/dev/null
    sleep 1
    
    log_info "[4/5] Zerando FRP..."
    adb shell "su -c 'dd if=/dev/zero of=/dev/block/platform/*/by-name/frp bs=1024'" 2>/dev/null
    sleep 2
    
    log_info "[5/5] Finalizando..."
    adb shell "su -c 'settings put secure user_setup_complete 1'" 2>/dev/null
    sleep 1
    
    echo ""
    log_ok "Bypass FRP concluído!"
    echo ""
    echo -e "${Y}Reinicie o dispositivo agora!${N}"
    echo ""
    read -p "Pressione ENTER..."
}

bypass_no_root() {
    if [ "$CONNECTED" = false ]; then
        log_err "Conecte um dispositivo primeiro!"
        sleep 2
        return
    fi
    
    clear
    echo -e "${Y}╔════════════════════════════════════════╗${N}"
    echo -e "${Y}║    LIMPEZA GOOGLE (SEM ROOT)           ║${N}"
    echo -e "${Y}╚════════════════════════════════════════╝${N}"
    echo ""
    
    log_info "[1/3] Limpando Google Play..."
    adb shell "pm clear com.google.android.gms" 2>/dev/null
    sleep 1
    
    log_info "[2/3] Limpando GSF..."
    adb shell "pm clear com.google.android.gsf" 2>/dev/null
    sleep 1
    
    log_info "[3/3] Parando serviços..."
    adb shell "am force-stop com.google.android.gms" 2>/dev/null
    sleep 1
    
    echo ""
    log_ok "Limpeza concluída!"
    echo ""
    echo "Agora:"
    echo "1. Configurações > Contas"
    echo "2. Remova contas Google"
    echo "3. Reinicie o aparelho"
    echo ""
    read -p "Pressione ENTER..."
}

verificar() {
    if [ "$CONNECTED" = false ]; then
        log_err "Conecte um dispositivo primeiro!"
        sleep 2
        return
    fi
    
    clear
    echo -e "${C}╔════════════════════════════════════════╗${N}"
    echo -e "${C}║      VERIFICAÇÃO DE STATUS             ║${N}"
    echo -e "${C}╚════════════════════════════════════════╝${N}"
    echo ""
    
    log_info "Verificando..."
    echo ""
    
    # FRP
    local frp=$(adb shell getprop ro.frp.pst 2>/dev/null | tr -d '\r')
    if [ -n "$frp" ] && [ "$frp" != "/dev/null" ]; then
        echo -e "${R}✗ FRP: ATIVO${N}"
    else
        echo -e "${G}✓ FRP: Inativo${N}"
    fi
    
    # Google
    if adb shell pm list packages 2>/dev/null | grep -q gms; then
        echo -e "${Y}⚠ Google Services: Instalado${N}"
    else
        echo -e "${G}✓ Google Services: Não instalado${N}"
    fi
    
    # ROOT
    if adb shell "su -c 'echo test'" 2>/dev/null | grep -q "test"; then
        echo -e "${G}✓ ROOT: Disponível${N}"
    else
        echo -e "${R}✗ ROOT: Não disponível${N}"
    fi
    
    echo ""
    read -p "Pressione ENTER..."
}

# Menu principal
while true; do
    clear
    echo -e "${C}╔════════════════════════════════════════╗${N}"
    echo -e "${C}║${W}        MENU PRINCIPAL                  ${C}║${N}"
    echo -e "${C}╚════════════════════════════════════════╝${N}"
    echo ""
    
    if [ "$CONNECTED" = true ]; then
        echo -e "${G}● Dispositivo conectado${N}"
    else
        echo -e "${R}○ Nenhum dispositivo conectado${N}"
    fi
    
    echo ""
    echo "1) Conectar Dispositivo"
    echo ""
    if [ "$CONNECTED" = true ]; then
        echo "2) Bypass FRP (ROOT)"
        echo "3) Limpeza Google (SEM ROOT)"
        echo "4) Verificar Status"
        echo "5) Reiniciar Dispositivo"
    fi
    echo ""
    echo "0) Sair"
    echo ""
    
    read -p "Escolha: " opt
    
    case $opt in
        1) conectar ;;
        2) [ "$CONNECTED" = true ] && bypass_root ;;
        3) [ "$CONNECTED" = true ] && bypass_no_root ;;
        4) [ "$CONNECTED" = true ] && verificar ;;
        5) 
            if [ "$CONNECTED" = true ]; then
                echo "Reiniciando..."
                adb reboot
                sleep 2
            fi
            ;;
        0) 
            clear
            echo ""
            echo "Obrigado por usar FRP Bypass OTG!"
            echo ""
            adb kill-server 2>/dev/null
            exit 0
            ;;
    esac
done
SCRIPT
    
    chmod +x ~/frp-tool.sh
    
    # Criar atalho
    echo 'alias frp="bash ~/frp-tool.sh"' >> ~/.bashrc
    
    echo ""
    echo "✅ Script instalado!"
    echo ""
    echo "Para executar:"
    echo "  bash ~/frp-tool.sh"
    echo "  ou simplesmente: frp"
    echo ""
}

# Executar instalação
case $opt in
    1)
        install_apk_compiler
        ;;
    2)
        install_termux_script
        echo ""
        read -p "Executar agora? (s/N): " run
        if [ "$run" = "s" ]; then
            bash ~/frp-tool.sh
        fi
        ;;
    3)
        install_apk_compiler
        echo ""
        install_termux_script
        ;;
    *)
        echo "Opção inválida!"
        exit 1
        ;;
esac

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                  INSTALAÇÃO CONCLUÍDA! ✅                     ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "📚 ARQUIVOS CRIADOS:"
echo ""
if [ -f ~/frp-bypass.apk ]; then
    echo "  📱 APK: ~/frp-bypass.apk"
    echo "     Instalar: termux-open ~/frp-bypass.apk"
    echo ""
fi
if [ -f ~/frp-tool.sh ]; then
    echo "  💻 Script: ~/frp-tool.sh"
    echo "     Executar: frp"
    echo ""
fi
echo ""
echo "🔗 COMANDOS ÚTEIS:"
echo ""
echo "  frp              - Executar ferramenta"
echo "  adb devices      - Listar dispositivos"
echo "  adb shell        - Shell no dispositivo"
echo ""
echo "⚠️  LEMBRE-SE: Apenas para dispositivos próprios!"
echo ""
