alter table "public"."users" drop column "first_name";

alter table "public"."users" drop column "last_name";

alter table "public"."users" add column "name" character varying(255) not null;


