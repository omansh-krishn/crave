TAG=$(curl -s https://api.github.com/repos/accupara/crave/releases/latest | jq -r '.tag_name')
BIN=$(curl -s https://api.github.com/repos/accupara/crave/releases/latest | jq -r '.assets[] | .name' | grep linux-amd64)
URL=https://github.com/accupara/crave/releases/download/${TAG}/${BIN}

wget $URL
chmod +x ${BIN}
mv ${BIN} crave
