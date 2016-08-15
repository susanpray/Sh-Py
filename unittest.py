import unittest
import numbers

class Mytest(unittest.TestCase):
    def average(self,numbers):
        return sum(numbers) / len(numbers)
    
    def test_average(self):
        self.assertEquals(self.average(1, 2, 3), 2)
        self.assertEquals(self.average(1, -3), 1)
        self.assertEquals(self.average(0, 1), 0.5)
        self.assertRaises(TypeError, self.average)
        

unittest.main()    