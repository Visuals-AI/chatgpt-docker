#!/usr/bin/env python
# -*- coding: utf-8 -*-
# --------------------------------------------
# 生成 ChatGPT WEB 页面的登录帐密（BasicAuth）
# --------------------------------------------

import argparse
from passlib.apache import HtpasswdFile

BASICAUTH_FILEPATH = '.basicauth'

def args() :
    parser = argparse.ArgumentParser(
        prog='生成 ChatGPT WEB 页面的登录帐密（BasicAuth）', # 会被 usage 覆盖
        usage='python ./py/gen_basicauth.py -u {USERNAME} -p {PASSWORD}',  
        description='生成 ChatGPT WEB 页面的登录帐密（BasicAuth）',  
        epilog='python ./py/gen_basicauth.py -h'
    )
    parser.add_argument('-u', '--username', dest='username', type=str, default='chatgpt', help='BasicAuth Username')
    parser.add_argument('-p', '--password', dest='password', type=str, default='TPGtahc#654321', help='BasicAuth Password')
    parser.add_argument('-f', '--filepath', dest='filepath', type=str, default=BASICAUTH_FILEPATH, help='BasicAuth Filepath')
    return parser.parse_args()


def main(args) :

    # 创建一个新的 HtpasswdFile 对象
    htpasswd = HtpasswdFile(args.filepath, new=True)

    # 添加用户和密码
    htpasswd.set_password(args.username, args.password)

    # 保存文件
    htpasswd.save()


if __name__ == '__main__' :
    main(args())

