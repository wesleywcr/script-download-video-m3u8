#!/bin/bash

# Verifica se o ffmpeg está instalado
if ! command -v ffmpeg &> /dev/null; then
    echo "Erro: ffmpeg não foi encontrado. Instale-o primeiro."
    exit 1
fi

# Solicita o link
read -p "Cole o link do .m3u8: " LINK

# Validação simples
if [[ -z "$LINK" ]]; then
    echo "Erro: link inválido."
    exit 1
fi

# Solicita o nome do arquivo
read -p "Digite o nome do arquivo de saída (ex: video ou video.mp4): " OUTPUT

# Remove espaços
OUTPUT=$(echo "$OUTPUT" | tr -d ' ')

# Se não tiver extensão, adiciona .mp4
if [[ "$OUTPUT" != *.* ]]; then
    OUTPUT="${OUTPUT}.mp4"
fi

# Se tiver extensão diferente de mp4, alerta
EXT="${OUTPUT##*.}"
if [[ "$EXT" != "mp4" ]]; then
    echo "Aviso: extensão .$EXT detectada. Recomendado usar .mp4"
fi

echo "Iniciando download..."
echo "Arquivo de saída: $OUTPUT"

# Download do stream m3u8
ffmpeg -y \
    -i "$LINK" \
    -c copy \
    -bsf:a aac_adtstoasc \
    "$OUTPUT"

# Verifica sucesso
if [[ $? -eq 0 ]]; then
    echo "✅ Download concluído com sucesso: $OUTPUT"
else
    echo "❌ Erro ao baixar o vídeo."
fi
