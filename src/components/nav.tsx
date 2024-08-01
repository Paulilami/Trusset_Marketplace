// components/nav.tsx
"use client";
import React, { useEffect, useRef, useState } from "react";
import { ArrowLeft } from "lucide-react";
import { Box, Button, Link, useTheme } from "@mui/material";
import ConnectButton from "./ConnectButton";
import ButtonDropDown from "./ButtonDropDown";
import { ButtonColorMode } from "./ButtonColorMode";

const Navigation: React.FC = () => {
  const ref = useRef<HTMLElement>(null);
  const [isIntersecting, setIntersecting] = useState(true);
  const theme = useTheme();  // Get the current theme

  useEffect(() => {
    if (!ref.current) return;
    const observer = new IntersectionObserver(([entry]) =>
      setIntersecting(entry.isIntersecting)
    );

    observer.observe(ref.current);
    return () => observer.disconnect();
  }, []);

  return (
    <Box ref={ref} sx={{ backgroundColor: theme.palette.background.default }}>
      <Box>
        <Box className="container flex flex-row-reverse items-center justify-between p-6 mx-auto" >
          <Box className="flex justify-between gap-8 text-center" sx={{alignItems:"center"}}>
            <Link href="/projects" underline="none" sx={{ color: theme.palette.text.primary }}>
              Projects
            </Link>
            <Link href="/contact" sx={{ color: theme.palette.text.secondary }} underline="none">
              Contact
            </Link>
            <ButtonDropDown
              title="F"
              aria-haspopup="true"
              sx={{
                variant:"",
                color: theme.palette.text.primary,
                m: 0,
                p: 0,
                typography: "body2",
                ":hover": { bgcolor: "transparent" },
                
              }}
              buttonProps={{disableRipple: true}}
            >
            <ConnectButton />
            </ButtonDropDown>
            <ButtonColorMode />
          </Box>
          <Link href="/" sx={{ color: theme.palette.text.primary }} underline="none">
            <ArrowLeft className="w-6 h-6 " />
          </Link>
        </Box>
      </Box>
    </Box>
  );
};

export default Navigation;
