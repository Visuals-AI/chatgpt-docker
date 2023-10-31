#!/usr/bin/env python
# -*- coding: utf-8 -*-
# --------------------------------------------
# 简易日志服务器，用于接收 ChatGPT 前端日志
# --------------------------------------------

import base64
import argparse
from color_log.clog import log
from flask import Flask, request, jsonify
from flask_cors import CORS

APP = Flask(__name__)
CORS(APP)   # 允许跨域


def args() :
    parser = argparse.ArgumentParser(
        prog='部署用于接受 ChatGPT WEB 页面日志的服务器', # 会被 usage 覆盖
        usage='python ./py/log_server.py -s {host} -p {PORT}',  
        description='部署用于接受 ChatGPT WEB 页面日志的服务器',  
        epilog='python ./py/log_server.py -h'
    )
    parser.add_argument('-s', '--host', dest='host', type=str, default='0.0.0.0', help='日志服务监听 IP')
    parser.add_argument('-p', '--port', dest='port', type=int, default=5000, help='日志服务监听端口')
    return parser.parse_args()


def main(args) :
    APP.run(host=args.host, port=args.port)



@APP.route('/tolog', methods=['POST'])
def tolog():
    data = request.json
    base64_msg = data.get('message', '')
    msg = unbase64(base64_msg)
    log.info(msg)
    return jsonify({"status": "success"}), 200


def unbase64(text) :
    decoded_bytes = base64.b64decode(text)
    return decoded_bytes.decode('utf-8')


if __name__ == "__main__":
    main(args())