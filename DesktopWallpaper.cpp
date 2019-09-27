﻿
#include "stdafx.h"

#include "resource.h"

#include <windows.h>
#include <shellapi.h>
#include <WinUser.h>
#include <tchar.h>
#include <cmath>
#include <iostream>
#include <cstdio>
#include <string>
#include <iomanip>
#include <sstream>
#include <fstream>
#include <io.h>
#include <fcntl.h>
#include <chrono>
#include <thread>
#include <vector>
#include <GL/glew.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <GLFW/glfw3.h>

// #define PRINT_WINDOWS_ENUM
#include "WorkerWEnumerator.h"

// Ling OpenGL
#pragma comment(lib, "opengl32.lib")
#pragma comment(lib, "glu32.lib")

// For freopen
#pragma warning(disable : 4996)

using WorkerWEnumerator::enumerateForWorkerW;

// Appication properties
// #define DISPLAY_CONSOLE_WINDOW
#define FRAME_DELAY 33.3

// Window properties
HWND gl_window;
HDC gl_device;
HGLRC gl_context;
HPALETTE hPalette = 0;
int gl_width;
int gl_height;

// Tray window properties
HINSTANCE trayHInst;
HMENU trayPopMenu;
HWND tray_window;

#define MAX_LOADSTRING 100
TCHAR trayWindowClass[MAX_LOADSTRING];
TCHAR trayTitle[MAX_LOADSTRING];
NOTIFYICONDATA trayNidApp;
#define	WM_USER_SHELLICON WM_USER + 1

// Runtime variables
// Shader program
GLuint shaderProgramId;
GLuint VBO, VAO, EBO;
float vertices[] = {
	 1.0f,  1.0f,
	 1.0f, -1.0f,
	-1.0f, -1.0f,
	-1.0f,  1.0f,
};
GLuint indices[] = {
	0, 1, 2,
	2, 3, 0
};

// Used in iTimeDelta
float timestamp = 0.0;
// Used in iFrame
int framestamp  = 0;

// Read shader from file & compile
GLuint LoadShaders(const char* vertex_file_path, const char* fragment_file_path) {

	// Creating shaders
	GLuint VertexShaderID = glCreateShader(GL_VERTEX_SHADER);
	GLuint FragmentShaderID = glCreateShader(GL_FRAGMENT_SHADER);

	// Loading vertex shader from file
	std::string VertexShaderCode;
	std::ifstream VertexShaderStream(vertex_file_path, std::ios::in);
	if (VertexShaderStream.is_open()) {
		std::stringstream sstr;
		sstr << VertexShaderStream.rdbuf();
		VertexShaderCode = sstr.str();
		VertexShaderStream.close();
	} else
		std::wcout << vertex_file_path << " open failed" << std::endl;

	// Loading fragment shader from file
	std::string FragmentShaderCode;
	std::ifstream FragmentShaderStream(fragment_file_path, std::ios::in);
	if (FragmentShaderStream.is_open()) {
		std::stringstream sstr;
		sstr << FragmentShaderStream.rdbuf();
		FragmentShaderCode = sstr.str();
		FragmentShaderStream.close();
	} else
		std::wcout << fragment_file_path << " open failed" << std::endl;

	GLint Result = GL_FALSE;
	int InfoLogLength;

	// Compiling vertex shader
	std::wcout << "Compiling shader: " << vertex_file_path << std::endl;
	char const* VertexSourcePointer = VertexShaderCode.c_str();
	glShaderSource(VertexShaderID, 1, &VertexSourcePointer, NULL);
	glCompileShader(VertexShaderID);

	// Checking vertex shader
	glGetShaderiv(VertexShaderID, GL_COMPILE_STATUS, &Result);
	glGetShaderiv(VertexShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength);
	if (InfoLogLength > 0) {
		std::vector<char> VertexShaderErrorMessage(InfoLogLength + 1);
		glGetShaderInfoLog(VertexShaderID, InfoLogLength, NULL, &VertexShaderErrorMessage[0]);
		std::wcout << &VertexShaderErrorMessage[0] << std::endl;
	}

	// Compiling fragment shader
	std::wcout << "Compiling shader: " << fragment_file_path << std::endl;
	char const* FragmentSourcePointer = FragmentShaderCode.c_str();
	glShaderSource(FragmentShaderID, 1, &FragmentSourcePointer, NULL);
	glCompileShader(FragmentShaderID);

	// Checking fragment shader
	glGetShaderiv(FragmentShaderID, GL_COMPILE_STATUS, &Result);
	glGetShaderiv(FragmentShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength);
	if (InfoLogLength > 0) {
		std::vector<char> FragmentShaderErrorMessage(InfoLogLength + 1);
		glGetShaderInfoLog(FragmentShaderID, InfoLogLength, NULL, &FragmentShaderErrorMessage[0]);
		std::wcout << &FragmentShaderErrorMessage[0] << std::endl;
	}

	// Creating shader program & attaching shaders to it
	std::wcout << "Creating shader program" << std::endl;
	GLuint ProgramID = glCreateProgram();
	glAttachShader(ProgramID, VertexShaderID);
	glAttachShader(ProgramID, FragmentShaderID);
	glLinkProgram(ProgramID);

	// Checking shader program
	glGetProgramiv(ProgramID, GL_LINK_STATUS, &Result);
	glGetProgramiv(ProgramID, GL_INFO_LOG_LENGTH, &InfoLogLength);
	if (InfoLogLength > 0) {
		std::vector<char> ProgramErrorMessage(InfoLogLength + 1);
		glGetProgramInfoLog(ProgramID, InfoLogLength, NULL, &ProgramErrorMessage[0]);
		std::wcout << &ProgramErrorMessage[0] << std::endl;
	}

	glDeleteShader(VertexShaderID);
	glDeleteShader(FragmentShaderID);

	// Returning shader program Id
	return ProgramID;
}

// Initialize rendering on OpenGL context
void initSC() {
	glViewport(0, 0, gl_width, gl_height);
	glClearColor(0, 0, 0, 0);

	shaderProgramId = LoadShaders("vertex_shader.glsl", "fragment_shader.glsl");

	glfwSetTime(0.0);
	timestamp = 0.0;

	glGenVertexArrays(1, &VAO);
	glGenBuffers(1, &VBO);
	glGenBuffers(1, &EBO);

	glBindVertexArray(VAO);

	glBindBuffer(GL_ARRAY_BUFFER, VBO);
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

	glVertexAttribPointer(glGetAttribLocation(shaderProgramId, "position"), 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), (GLvoid*)0);
	glEnableVertexAttribArray(0);

	glBindBuffer(GL_ARRAY_BUFFER, 0);

	glBindVertexArray(0);
}

// Called on app exit
void destroySC() {};

// Callback for resize event for OpenGL
void resizeSC(int width, int height) {
	glViewport(0, 0, width, height);

	gl_width = width;
	gl_height = height;
}

// Callback for rendering a surface
void renderSC() {
	glClearColor(0, 0, 0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	glUniform3f(glGetUniformLocation(shaderProgramId, "iResolution"), (float) gl_width, (float) gl_height, 0.0);
	glUniform1f(glGetUniformLocation(shaderProgramId, "iTime"), (float) glfwGetTime());
	glUniform1f(glGetUniformLocation(shaderProgramId, "iTimeDelta"), (float) (glfwGetTime() - timestamp));
	timestamp = glfwGetTime();
	glUniform1i(glGetUniformLocation(shaderProgramId, "iFrame"), ++framestamp);

	glUseProgram(shaderProgramId);
	glBindVertexArray(VAO);
	//glDrawArrays(GL_TRIANGLES, 0, 6);
	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
	glBindVertexArray(0);

	glFlush();
	SwapBuffers(gl_device);
}

// Tray event dispatcher
LONG WINAPI trayWindowProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
	int wmId, wmEvent;
	POINT lpClickPoint;

	switch (uMsg) {
		case WM_USER_SHELLICON:
			switch (LOWORD(lParam)) {
				case WM_RBUTTONDOWN:
					UINT uFlag = MF_BYPOSITION | MF_STRING;
					GetCursorPos(&lpClickPoint);
					trayPopMenu = CreatePopupMenu();

					// InsertMenu(trayPopMenu, 0xFFFFFFFF, MF_SEPARATOR, IDM_SEP, _T("SEP"));
					InsertMenu(trayPopMenu, 0xFFFFFFFF, MF_BYPOSITION | MF_STRING, IDM_EXIT, _T("Exit"));

					SetForegroundWindow(hWnd);
					TrackPopupMenu(trayPopMenu, TPM_LEFTALIGN | TPM_LEFTBUTTON | TPM_BOTTOMALIGN, lpClickPoint.x, lpClickPoint.y, 0, hWnd, NULL);
					return TRUE;

			}
			break;

		case WM_COMMAND:
			wmId = LOWORD(wParam);
			wmEvent = HIWORD(wParam);

			switch (wmId) {
				case IDM_EXIT:
					Shell_NotifyIcon(NIM_DELETE, &trayNidApp);
					DestroyWindow(hWnd);
					DestroyWindow(gl_window);
					break;
				default:
					return DefWindowProc(hWnd, wmId, wParam, lParam);
			}
			break;

		case WM_DESTROY:
			PostQuitMessage(0);
			break;

		default:
			return DefWindowProc(hWnd, uMsg, wParam, lParam);
	}

	return DefWindowProc(hWnd, uMsg, wParam, lParam);
}

// Event dispatcher
LONG WINAPI WindowProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
	static PAINTSTRUCT ps;

	switch (uMsg) {
		case WM_CREATE:
			return 0;

		case WM_PAINT:
			BeginPaint(hWnd, &ps);
			renderSC();
			EndPaint(hWnd, &ps);
			return 0;

		case WM_SIZE:
			resizeSC(LOWORD(lParam), HIWORD(lParam));
			PostMessage(hWnd, WM_PAINT, 0, 0);
			return 0;

		case WM_CHAR:
			switch (wParam) {
				case 27:			/* ESC key */
					PostQuitMessage(0);
					break;
			}
			return 0;

		case WM_DESTROY:
			PostQuitMessage(0);
			return 0;

		case WM_PALETTECHANGED:
			if (hWnd == (HWND)wParam)
				break;

		case WM_QUERYNEWPALETTE:
			if (hPalette) {
				UnrealizeObject(hPalette);
				SelectPalette(gl_device, hPalette, FALSE);
				RealizePalette(gl_device);
				return TRUE;
			}
			return FALSE;

		default:
			return DefWindowProc(hWnd, uMsg, wParam, lParam);
	}

	return DefWindowProc(hWnd, uMsg, wParam, lParam);
}

// Register OpenGL context for window
HWND CreateOpenGLWindow(LPWSTR title, int x, int y, int width, int height, BYTE type, DWORD flags) {
	int         n, pf;
	WNDCLASS    wc;
	LOGPALETTE* lpPal;
	PIXELFORMATDESCRIPTOR pfd;
	static HINSTANCE hInstance = 0;

	/* only register the window class once - use hInstance as a flag. */
	if (!hInstance) {
		hInstance = GetModuleHandle(NULL);
		wc.style = CS_OWNDC;
		wc.lpfnWndProc = (WNDPROC)WindowProc;
		wc.cbClsExtra = 0;
		wc.cbWndExtra = 0;
		wc.hInstance = hInstance;
		wc.hIcon = LoadIcon(NULL, IDI_WINLOGO);
		wc.hCursor = LoadCursor(NULL, IDC_ARROW);
		wc.hbrBackground = NULL;
		wc.lpszMenuName = NULL;
		wc.lpszClassName = L"OpenGL";

		if (!RegisterClass(&wc)) {
			MessageBox(NULL, L"RegisterClass() failed:  "
				"Cannot register window class.", L"Error", MB_OK);
			return NULL;
		}
	}

	// Create window for OpenGL
	gl_window = CreateWindow(L"OpenGL", title, WS_OVERLAPPEDWINDOW |
		WS_CLIPSIBLINGS | WS_CLIPCHILDREN,
		x, y, width, height, NULL, NULL, hInstance, NULL);

	if (gl_window == NULL) {
		MessageBox(NULL, L"CreateWindow() failed:  Cannot create a window.",
			L"Error", MB_OK);
		return NULL;
	}

	DWORD style = ::GetWindowLong(gl_window, GWL_STYLE);
	style &= ~WS_OVERLAPPEDWINDOW;
	style |= WS_POPUP;
	::SetWindowLong(gl_window, GWL_STYLE, style);

	gl_device = GetDC(gl_window);

	memset(&pfd, 0, sizeof(pfd));
	pfd.nSize = sizeof(pfd);
	pfd.nVersion = 1;
	pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | flags;
	pfd.iPixelType = type;
	pfd.cColorBits = 32;

	// Choose pixel format
	pf = ChoosePixelFormat(gl_device, &pfd);
	if (pf == 0) {
		MessageBox(NULL, L"ChoosePixelFormat() failed:  "
			"Cannot find a suitable pixel format.", L"Error", MB_OK);
		return 0;
	}

	if (SetPixelFormat(gl_device, pf, &pfd) == FALSE) {
		MessageBox(NULL, L"SetPixelFormat() failed:  "
			"Cannot set format specified.", L"Error", MB_OK);
		return 0;
	}

	DescribePixelFormat(gl_device, pf, sizeof(PIXELFORMATDESCRIPTOR), &pfd);

	if (pfd.dwFlags & PFD_NEED_PALETTE ||
		pfd.iPixelType == PFD_TYPE_COLORINDEX) {

		n = 1 << pfd.cColorBits;
		if (n > 256) n = 256;

		lpPal = (LOGPALETTE*)malloc(sizeof(LOGPALETTE) +
			sizeof(PALETTEENTRY) * n);
		if (!lpPal)
			return NULL;

		memset(lpPal, 0, sizeof(LOGPALETTE) + sizeof(PALETTEENTRY) * n);
		lpPal->palVersion = 0x300;
		lpPal->palNumEntries = n;

		GetSystemPaletteEntries(gl_device, 0, n, &lpPal->palPalEntry[0]);

		if (pfd.iPixelType == PFD_TYPE_RGBA) {
			int redMask = (1 << pfd.cRedBits) - 1;
			int greenMask = (1 << pfd.cGreenBits) - 1;
			int blueMask = (1 << pfd.cBlueBits) - 1;
			int i;

			for (i = 0; i < n; ++i) {
				lpPal->palPalEntry[i].peRed =
					(((i >> pfd.cRedShift) & redMask) * 255) / redMask;
				lpPal->palPalEntry[i].peGreen =
					(((i >> pfd.cGreenShift) & greenMask) * 255) / greenMask;
				lpPal->palPalEntry[i].peBlue =
					(((i >> pfd.cBlueShift) & blueMask) * 255) / blueMask;
				lpPal->palPalEntry[i].peFlags = 0;
			}
		} else {
			lpPal->palPalEntry[0].peRed = 0;
			lpPal->palPalEntry[0].peGreen = 0;
			lpPal->palPalEntry[0].peBlue = 0;
			lpPal->palPalEntry[0].peFlags = PC_NOCOLLAPSE;
			lpPal->palPalEntry[1].peRed = 255;
			lpPal->palPalEntry[1].peGreen = 0;
			lpPal->palPalEntry[1].peBlue = 0;
			lpPal->palPalEntry[1].peFlags = PC_NOCOLLAPSE;
			lpPal->palPalEntry[2].peRed = 0;
			lpPal->palPalEntry[2].peGreen = 255;
			lpPal->palPalEntry[2].peBlue = 0;
			lpPal->palPalEntry[2].peFlags = PC_NOCOLLAPSE;
			lpPal->palPalEntry[3].peRed = 0;
			lpPal->palPalEntry[3].peGreen = 0;
			lpPal->palPalEntry[3].peBlue = 255;
			lpPal->palPalEntry[3].peFlags = PC_NOCOLLAPSE;
		}

		hPalette = CreatePalette(lpPal);
		if (hPalette) {
			SelectPalette(gl_device, hPalette, FALSE);
			RealizePalette(gl_device);
		}

		free(lpPal);
	}

	// Create GL context
	gl_context = wglCreateContext(gl_device);
	wglMakeCurrent(gl_device, gl_context);

	// Initialize GLFW
	if (!glfwInit()) {
		std::wcout << "GLFW initialization failed" << std::endl;
		return NULL;
	}

	// Initialize GLEW
	glewExperimental = GL_TRUE;
	if (GLEW_OK != glewInit()) {
		std::wcout << "GLEW initialization failed" << std::endl;
		return NULL;
	}

	gl_width = width;
	gl_height = height;

	// Call user init handler
	initSC();

	ReleaseDC(gl_window, gl_device);

	return gl_window;
};

// Create tray window class
ATOM MyRegisterTrayClass(HINSTANCE hInstance) {
	WNDCLASSEX wcex;

	wcex.cbSize = sizeof(WNDCLASSEX);

	wcex.style = CS_HREDRAW | CS_VREDRAW;
	wcex.lpfnWndProc = trayWindowProc;
	wcex.cbClsExtra = 0;
	wcex.cbWndExtra = 0;
	wcex.hInstance = hInstance;
	wcex.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_ICON));
	wcex.hCursor = LoadCursor(NULL, IDC_ARROW);
	wcex.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
	wcex.lpszMenuName = L"MenuName";
	wcex.lpszClassName = trayWindowClass;
	wcex.hIconSm = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_ICON));

	return RegisterClassEx(&wcex);
}

// init tray window application
BOOL InitTrayInstance(HINSTANCE hInstance, int nCmdShow) {
	HICON hMainIcon;

	trayHInst = hInstance; // Store instance handle in our global variable

	tray_window = CreateWindow(trayWindowClass, trayTitle, WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, NULL, NULL, hInstance, NULL);

	if (!tray_window) {
		return FALSE;
	}

	hMainIcon = LoadIcon(hInstance, (LPCTSTR) MAKEINTRESOURCE(IDI_ICON));

	trayNidApp.cbSize = sizeof(NOTIFYICONDATA); // sizeof the struct in bytes 
	trayNidApp.hWnd = (HWND) tray_window;              //handle of the window which will process this app. messages 
	trayNidApp.uID = IDI_ICON;           //ID of the icon that willl appear in the system tray 
	trayNidApp.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP; //ORing of all the flags 
	trayNidApp.hIcon = hMainIcon; // handle of the Icon to be displayed, obtained from LoadIcon 
	trayNidApp.uCallbackMessage = WM_USER_SHELLICON;
	LoadString(hInstance, IDS_APPTOOLTIP, trayNidApp.szTip, MAX_LOADSTRING);
	Shell_NotifyIcon(NIM_ADD, &trayNidApp);

	return TRUE;
}

// Entry
int WINAPI __stdcall wWinMain(HINSTANCE hInstance, HINSTANCE, PWSTR pCmdLine, int nCmdShow) {
#ifdef DISPLAY_CONSOLE_WINDOW
	// Open console window
	AllocConsole();
	FILE* _freo = freopen("CONOUT$", "w+", stdout);
#endif

	// Output unicode text
	int _sm = _setmode(_fileno(stdout), _O_U16TEXT);

	// Create tray window
	LoadString(hInstance, IDS_APP_TITLE, trayTitle, MAX_LOADSTRING);
	LoadString(hInstance, IDC_WNDCLASS, trayWindowClass, MAX_LOADSTRING);

	MyRegisterTrayClass(hInstance);

	if (!InitTrayInstance(hInstance, nCmdShow)) {
		return FALSE;
	}

	// Get WorkerW layer
	HWND workerw = enumerateForWorkerW();

	if (workerw == NULL) {
		std::wcerr << "WorkerW enumeration fail" << std::endl;
		exit(1);
	}

	// Get size of WorkerW. Entire desktop background
	RECT windowsize;
	GetWindowRect(workerw, &windowsize);

	// Create WIndows & OpenGL context
	CreateOpenGLWindow((LPWSTR) L"minimal", windowsize.left, windowsize.top, windowsize.right, windowsize.bottom, PFD_TYPE_RGBA, 0);
	if (gl_window == NULL) {
		std::wcout << "GL creation failed" << std::endl;
		exit(1);
	}

	// push window to desktop background
	SetParent(gl_window, workerw);

	// Display & call first frame draw
	ShowWindow(gl_window, nCmdShow);
	UpdateWindow(gl_window);

	std::chrono::system_clock::time_point a = std::chrono::system_clock::now();
	std::chrono::system_clock::time_point b = std::chrono::system_clock::now();

	MSG msg1;
	MSG msg2;

	// Main repaint loop, limited by FPS
	while (1) {
		a = std::chrono::system_clock::now();
		std::chrono::duration<double, std::milli> work_time = a - b;

		while (PeekMessage(&msg1, tray_window, 0, 0, PM_NOREMOVE)) {
			if (GetMessage(&msg1, tray_window, 0, 0)) {
				TranslateMessage(&msg1);
				DispatchMessage(&msg1);
			} else
				goto quit;
		}

		while (PeekMessage(&msg2, gl_window, 0, 0, PM_NOREMOVE)) {
			if (GetMessage(&msg2, gl_window, 0, 0)) {
				TranslateMessage(&msg2);
				DispatchMessage(&msg2);
			} else
				goto quit;
		}

		if (msg1.message == WM_QUIT || msg2.message == WM_QUIT)
			goto quit;

		renderSC();

		if (work_time.count() < FRAME_DELAY) {
			std::chrono::duration<double, std::milli> delta_ms(FRAME_DELAY - work_time.count());
			auto delta_ms_duration = std::chrono::duration_cast<std::chrono::milliseconds>(delta_ms);
			std::this_thread::sleep_for(std::chrono::milliseconds(delta_ms_duration.count()));
		}

		b = std::chrono::system_clock::now();
	}

quit:

	destroySC();
	wglMakeCurrent(NULL, NULL);
	ReleaseDC(gl_window, gl_device);
	wglDeleteContext(gl_context);
	DestroyWindow(gl_window);
	if (hPalette)
		DeleteObject(hPalette);

	return msg2.wParam;
};