<%@ page import="com.mellisa.aucaregistrationsystem.model.Users" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div class="fixed inset-y-0 left-0 w-64 bg-blue-500 text-white p-6 flex flex-col space-y-6">
    <div class="space-x-4">
        <%
            Users loggedInUser = (Users) session.getAttribute("loggedInUser");
            if (loggedInUser == null || !"Admin".equalsIgnoreCase(loggedInUser.getRole().toString())) {
                response.sendRedirect("login");
                return;
            }
            String profilePictureUrl = loggedInUser.getProfilePictureUrl() != null ? loggedInUser.getProfilePictureUrl() : "/uploads/logo.png";
        %>
        <div class="flex flex-col items-center mb-8">
            <img src="<%= profilePictureUrl %>" alt="Profile Picture" class="w-16 h-16 rounded-full border-2 border-white mb-2">
            <span class="text-lg font-semibold"><%= loggedInUser.getFirstName() != null ? " " + loggedInUser.getFirstName() : "Admin" %></span>
        </div>
    </div>

    <h2 class="text-xl font-bold mb-4 text-left p-2" data-i18n="dashboardTitle"></h2>

    <nav class="flex flex-col space-y-2">
        <a href="/admin/courses" class="flex items-center justify-start hover:bg-blue-700 p-2 rounded-md transition-colors duration-200">
<%--            <span class="material-icons-sharp mr-2">book</span>--%>
            <span data-i18n="allCourses"></span>
        </a>
        <a href="/admin/registrations" class="flex items-center justify-start hover:bg-blue-700 p-2 rounded-md transition-colors duration-200">
<%--            <span class="material-icons-sharp mr-2">assignment</span>--%>
            <span data-i18n="registrationRequests"></span>
        </a>
        <a href="/admin/insights" class="flex items-center justify-start hover:bg-blue-700 p-2 rounded-md transition-colors duration-200">
<%--            <span class="material-icons-sharp mr-2">insights</span>--%>
            <span data-i18n="insights"></span>
        </a>

        <div class="flex flex-col space-y-2">
            <label for="languageSelect" class="font-bold px-2" data-i18n="chooseLanguage"></label>
            <select id="languageSelect" onchange="changeLanguage()"  class="bg-blue-500 text-white border border-blue-400 rounded-md p-2 ml-2 focus:outline-none focus:ring-2 focus:ring-blue-300">
                <option name="language" value="en">English</option>
                <option name="language" value="es">Español</option>
                <option name="language" value="rw">Kinyarwanda</option>
                <option name="language" value="fr">Français</option>
            </select>
        </div>

        <a href="/logout" class="flex items-center justify-start hover:bg-blue-700 p-2 rounded-md transition-colors duration-200">
<%--            <span class="material-icons-sharp mr-2">logout</span>--%>
            <span data-i18n="logout"></span>
        </a>
    </nav>
</div>

<script src="https://unpkg.com/i18next/dist/umd/i18next.min.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const resources = {
            en: {
                translation: {
                    dashboardTitle: "Admin Dashboard",
                    allCourses: "All Courses",
                    registrationRequests: "Registration Requests",
                    insights: "Registration Insights",
                    chooseLanguage: "Choose Language:",
                    logout: "Logout",
                    registrationInsightsTitle: "Registration Insights",
                    statusDistributionTitle: "Registration Status Distribution",
                    registrationsPerCourseTitle: "Registrations Per Course"
                }
            },
            es: {
                translation: {
                    dashboardTitle: "Panel de Administración",
                    allCourses: "Todos los Cursos",
                    registrationRequests: "Solicitudes de Registro",
                    insights: "Análisis de Registros",
                    chooseLanguage: "Elegir Idioma:",
                    logout: "Cerrar Sesión",
                    registrationInsightsTitle: "Información de Registro",
                    statusDistributionTitle: "Distribución del Estado de Registro",
                    registrationsPerCourseTitle: "Registros por Curso"
                }
            },
            fr: {
                translation: {
                    dashboardTitle: "Tableau de Bord Admin",
                    allCourses: "Tous les Cours",
                    registrationRequests: "Demandes d'Inscription",
                    insights: "Analyses des Inscriptions",
                    chooseLanguage: "Choisir la Langue:",
                    logout: "Déconnexion",
                    registrationInsightsTitle: "Aperçu des Inscriptions",
                    statusDistributionTitle: "Distribution des Statuts d'Inscription",
                    registrationsPerCourseTitle: "Inscriptions par Cours"
                }
            },
            rw: {
                translation: {
                    dashboardTitle: "Ikibaho cy'Umuyobozi",
                    allCourses: "Amasomo Yose",
                    registrationRequests: "Ibisabwa byo Kwiyandikisha",
                    insights: "Imibare y'Iyandikwa",
                    chooseLanguage: "Hitamo Ururimi:",
                    logout: "Sohoka",
                }
            }
        };


        // Initialize i18next
        i18next
            .init({
                lng: localStorage.getItem('preferredLanguage') || 'en',
                resources: resources,
                fallbackLng: 'en'
            })
            .then(function() {
                const selectElement = document.getElementById('languageSelect');
                if (selectElement) {
                    // selectElement.value = i18next.language;
                    updateContent();
                }
            });
    });

        // Global change function to be called from HTML
        window.changeLanguage = function() {
            const selectElement = document.getElementById('languageSelect');
            // const newLang = selectElement.value;
            const newLang = "es";
            console.log("Changing language to:", newLang);
            console.log("Selected  language :", selectElement.value);
            console.log("changeLanguage function triggered with value:", selectElement.value);


            localStorage.setItem('preferredLanguage', newLang);

            i18next.changeLanguage(newLang, function(err) {
                if (err) {
                    console.error('Error changing language:', err);
                    return;
                }
                updateContent();
                console.log("Language successfully In local storage to:", localStorage.getItem("preferredLanguage"));
            });
        };

        // Update content function
        function updateContent() {
            document.querySelectorAll('[data-i18n]').forEach(element => {
                const key = element.getAttribute('data-i18n');
                element.textContent = i18next.t(key);
            });
        }
</script>