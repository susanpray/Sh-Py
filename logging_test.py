#!/usr/bin python
# -*- coding: UTF-8 -*-

import logging


logging.basicConfig(filename='mylog.log', level=logging.DEBUG,
        format='%(asctime)s - %(levelname)s - %(name)s - %(funcName)s - %(lineno)d : %(message)s')


def logging_func():
    logger = logging.getLogger('hello')

    logger.info('Hello, world.')
    logger.debug('A debug info.')
    logger.error('An error.')
    logger.critical('Critical error.')


if __name__ == '__main__':

    logging_func()