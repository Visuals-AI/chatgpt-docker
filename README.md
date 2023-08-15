# chatgpt-docker
ChatGPT Docker


```
git submodule update --remote --recursive

python3 -m pip install -r py/requirements.txt
python3 py/gen_basicauth.py -u "chatgpt" -p "TPGtahc#654321"

bin/build.sh
bin/run.sh -k "${OPENAI_API_KEY}" -u "${USERNAME}" -p "${PASSWORD}" -s "host.docker.internal" -r 10089
```