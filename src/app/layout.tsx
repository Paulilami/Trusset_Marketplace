import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { AppRouterCacheProvider } from '@mui/material-nextjs/v13-appRouter';
import { ThemeProvider } from '@mui/material/styles';
import theme from './theme';
import Navigation from "@/components/nav";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Create Next App",
  description: "Generated by create next app",
};

export default function RootLayout(props:any) {
  const { children } = props;
  return (
    <html lang="en">
      <body>
         <AppRouterCacheProvider>
           <ThemeProvider theme={theme}>
              <Navigation/>
             {children}
           </ThemeProvider>
         </AppRouterCacheProvider>
      </body>
    </html>
  );
}
