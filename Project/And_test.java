class And_test {
    public static void main(String[] a) {
        test b;
        b = new test();
        //System.out.println(b.foo());
    }

}

class test {
    int y;
    int k;

    public int foo() {
        int x;
        boolean a;
        boolean b;
        b = true;
        a = false;
        if (a && b) {
            x = 0;
        } else {
            x = 1;
        }
        System.out.println(y * 3);

        return 0;
    }
}