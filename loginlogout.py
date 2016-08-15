# -*- coding: utf-8 -*-
import os
import unittest
import time
from yunmei import *
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from optparse import OptionParser
import logging

if __name__ == '__main__':
    uri = "http://zc.suning.com/"
    method = 'chrome'
    webtest = webtester(uri,method)
    time.sleep(10)
    ## webtest.driver.find_element_by_link_text(u"登录").click()
    ## webtest.driver.find_element_by_id('userName').send_keys('15295568019')
    ## webtest.driver.find_element_by_id('password').send_keys('123qwe')
    ## webtest.driver.find_element_by_id('submit').click()
    ## time.sleep(30)
    # webtest.driver.get(uri + "/project/browseList.htm")
    ## webtest.driver.find_element_by_link_text(u"退出登录").click()
    # webtest.driver.find_element_by_link_text(u"我的消息").click()
    #webtest.driver.find_element_by_name("jr_none_dbtool_myxx").click()
    m = webtest.driver.find_element_by_name("jr_none_dbtool_myyg")
    # m = webtest.driver.find_element_by_name("//a[@href='http://mypre.cnsuning.com']")
    webtest.driver.move_to_element(m).perform()
    # webtest.driver.find_element_by_xpath("//a[@href='http://msgpre.cnsuning.com']")
    webtest.driver.find_element_by_link_text(u"我的消息").click()
    time.sleep(10)
