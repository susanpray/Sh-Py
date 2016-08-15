#!/usr/bin python
# -*- coding: UTF-8 -*-

import argparse
local_product={'VmVersion':'5.5.5'}
def show_all(lang='Chinese', text_format=False):
    """显示所有版本信息"""
    if lang not in ['Chinese', 'English']:
        print 'Not Supported Language.'
    else:
#         show_product(lang, text_format)
#         show_details(lang, text_format)
#         show_content(lang, text_format)
#         show_system(lang, text_format)
        show_vm(lang, text_format)

def show_vm(lang='Chinese', text_format=False):
    """显示虚拟机镜像版本信息"""
    if 'VmVersion' in local_product:
        if lang == 'Chinese':
            header = '虚拟机信息' if text_format else '----------- 虚拟机信息 -----------'
        elif lang == 'English':
            header = 'Virtual-Machine' if text_format else '-------- Virtual Machine ---------'
        else:
            print 'Not Supported Language.'
            return

        vm_version = local_product['VmVersion']

        print '$'.join([header, vm_version]) if text_format else '\n'.join([header, vm_version])
    else:
        return


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--type", help="Show versions of this type: all/product/detail/content/system/vm",
                        type=str, required=False)
    parser.add_argument("-x", "--text", help="Show versions in text format", action="store_true", required=True)
    args = parser.parse_args()


    language = "Chinese"

    
    if args.type == 'vm':
        show_vm(language, args.text) 
	print args.text
    if args.type == 'all':
        show_vm(language, args.text)
