class Classes {
	public static void main(String[] a) {
		Base b;
		Derived d;
		boolean k;
		int c;

		b = new Base();
		d = new Derived();
		System.out.println(d.foo(2, true));
	}
}

class Base {
	int data;

	public int foo(int a) {
		return a;
	}

	public int foo2(Base b) {
		return 0;
	}

	public boolean foo3(Derived d, Base a, int c) {
		return false;
	}

}

class Derived extends Base {
	public int foo(int a, boolean b) {
		return 0;
	}

	public int test(int a, boolean b) {
		return 0;
	}
}
